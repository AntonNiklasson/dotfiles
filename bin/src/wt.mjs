#!/usr/bin/env zx

import { $, fs, glob, path } from 'zx'
import ora from 'ora'
import prompts from 'prompts'
import minimist from 'minimist'

const argv = minimist(process.argv.slice(3))

// Git Worktree Tool — run `wt` for usage

const hasPrompt = !!argv.prompt
if (!hasPrompt) {
  $.quiet = true
}

const command = argv._[0]

if (!command || !['new', 'switch', 'rm', 'setup'].includes(command)) {
  console.log('')
  console.log('Usage:')
  console.log('  wt new [name] [--branch BRANCH] [--prompt PROMPT] [--harness claude|opencode|shell]  - Create a new worktree')
  console.log('  wt switch               - Switch to existing worktree')
  console.log('  wt rm                   - Remove a worktree')
  console.log('  wt setup [path]         - Setup/reconfigure an existing worktree')
  process.exit(1)
}

// Ensure we're in a git repository
try {
  await $`git rev-parse --is-inside-work-tree`
} catch {
  console.log('Error: Not inside a git repository')
  process.exit(1)
}

// Get repo info
const gitCommonDir = (await $`cd "$(git rev-parse --git-common-dir)" && pwd`).stdout.trim()
const repoRoot = path.dirname(gitCommonDir)
const repoName = path.basename(repoRoot)
const parentDir = path.dirname(repoRoot)

let baseBranch
try {
  baseBranch = (await $`git symbolic-ref refs/remotes/origin/HEAD`).stdout.trim().replace('refs/remotes/origin/', '')
} catch {
  baseBranch = 'main'
}

const insideTmux = !!process.env.TMUX

let worktreePath
let windowName
let initialPrompt
let harness = 'shell'
let commands = []

async function pickWorktree(promptText, filterFn = () => true, { multi = false } = {}) {
  const wtListOutput = (await $`git worktree list`).stdout.trim()
  const wtLines = wtListOutput.split('\n').filter(filterFn)

  if (wtLines.length === 0) return multi ? [] : null

  const enriched = []
  for (const line of wtLines) {
    const wtPath = line.split(/\s+/)[0]
    const dirName = path.basename(wtPath)
    enriched.push(`${wtPath}\t${dirName}`)
  }

  const input = enriched.join('\n')
  const preview = "git -C {1} status --short"

  const fzfFlags = [
    `--prompt=${promptText}`,
    '--height=15',
    "--delimiter=\t",
    '--with-nth=2..',
    `--preview=${preview}`,
    '--preview-window=right:50%'
  ]
  if (multi) fzfFlags.push('--multi')

  let selection
  try {
    selection = (await $`echo ${input} | fzf ${fzfFlags}`).stdout.trim()
  } catch {
    return multi ? [] : null
  }

  if (multi) {
    return selection.split('\n').map(line => line.split('\t')[0]).filter(Boolean)
  }
  return selection.split('\t')[0]
}

if (command === 'switch') {
  worktreePath = await pickWorktree('Select worktree: ')
  if (!worktreePath) {
    console.log('No worktree selected')
    process.exit(0)
  }
  windowName = path.basename(worktreePath)

  // Check if a tmux window already exists for this worktree
  if (insideTmux) {
    try {
      const panes = (await $`tmux list-panes -a -F ${'#{session_name}:#{window_index} #{pane_current_path}'}`).stdout.trim()
      for (const line of panes.split('\n')) {
        const [windowTarget, panePath] = [line.split(' ')[0], line.split(' ').slice(1).join(' ')]
        if (panePath.startsWith(worktreePath)) {
          await $`tmux select-window -t ${windowTarget}`
          console.log(`Switched to existing window: ${windowTarget}`)
          process.exit(0)
        }
      }
    } catch {}
  }
}

if (command === 'rm') {
  const selectedPaths = await pickWorktree('Remove worktrees (Tab to select): ', (_, i) => i > 0, { multi: true })
  if (selectedPaths.length === 0) {
    console.log('No worktree selected')
    process.exit(0)
  }

  // First pass: confirm each worktree
  const confirmedPaths = []
  for (const wtPath of selectedPaths) {
    const wtName = path.basename(wtPath)

    // Check if worktree directory still exists
    if (!fs.existsSync(wtPath)) {
      console.log(`\n"${wtName}" directory is missing, will clean up git reference`)
      confirmedPaths.push(wtPath)
      continue
    }

    // Check for uncommitted changes
    const status = (await $`git -C ${wtPath} status --porcelain`).stdout.trim()
    if (status) {
      console.log(`\n"${wtName}" has uncommitted changes:\n`)
      console.log(status)
      console.log('')

      if (selectedPaths.length === 1) {
        const { showDiff } = await prompts({
          type: 'toggle',
          name: 'showDiff',
          message: 'Show full diff?',
          initial: true,
          active: 'yes',
          inactive: 'skip'
        })

        if (showDiff) {
          await $({ stdio: 'inherit' })`git -C ${wtPath} diff`.catch(() => { })
          console.log('')
        }
      }
    }

    const { confirmed } = await prompts({
      type: 'toggle',
      name: 'confirmed',
      message: `Remove worktree "${wtName}"?`,
      initial: false,
      active: 'yes',
      inactive: 'no'
    })

    if (confirmed) confirmedPaths.push(wtPath)
  }

  if (confirmedPaths.length === 0) {
    process.exit(0)
  }

  // Second pass: remove confirmed worktrees
  for (const wtPath of confirmedPaths) {
    const wtName = path.basename(wtPath)

    let s = ora(`Removing ${wtName}...`).start()
    try {
      await $`git worktree remove ${wtPath} --force`
    } catch { }
    await fs.remove(wtPath)
    s.succeed(`Removed ${wtName}`)

    // Kill tmux window whose pane cwd matches the worktree path
    if (insideTmux) {
      try {
        const panes = (await $`tmux list-panes -a -F ${'#{session_name}:#{window_index} #{pane_current_path}'}`).stdout.trim()
        for (const line of panes.split('\n')) {
          const [windowTarget, panePath] = [line.split(' ')[0], line.split(' ').slice(1).join(' ')]
          if (panePath.startsWith(wtPath)) {
            await $`tmux kill-window -t ${windowTarget}`
            break
          }
        }
      } catch { }
    }
  }

  process.exit(0)
}

if (command === 'new') {
  const hasFlags = argv.prompt || argv.branch
  let name = argv._[1]
  if (!name && !hasFlags) {
    const response = await prompts({
      type: 'text',
      name: 'name',
      message: 'Worktree name'
    })
    name = response.name
  }
  if (!name?.trim()) {
    if (hasFlags) {
      console.log('Error: name is required when using --prompt or --branch')
      console.log('Example: wt new my-feature --prompt "fix the thing"')
    } else {
      console.log('Name required')
    }
    process.exit(1)
  }

  let normalizedName = name.trim().replace(/[^a-zA-Z0-9_-]/g, '-')
  worktreePath = `${parentDir}/${repoName}--${normalizedName}`

  // Check if worktree path already exists
  if (fs.existsSync(worktreePath)) {
    const { action } = await prompts({
      type: 'select',
      name: 'action',
      message: `Path "${worktreePath}" exists`,
      choices: [
        { title: 'Remove existing', value: 'remove' },
        { title: 'Enter new name', value: 'rename' },
        { title: 'Abort', value: 'abort' }
      ]
    })
    if (action === 'remove') {
      await $`git worktree remove ${worktreePath} --force`.catch(() => { })
      await fs.remove(worktreePath)
    } else if (action === 'rename') {
      const { newName } = await prompts({
        type: 'text',
        name: 'newName',
        message: 'New worktree name'
      })
      if (!newName?.trim()) {
        console.log('Name required')
        process.exit(1)
      }
      normalizedName = newName.trim().replace(/[^a-zA-Z0-9_-]/g, '-')
      worktreePath = `${parentDir}/${repoName}--${normalizedName}`
    } else {
      process.exit(0)
    }
  }

  windowName = normalizedName
  const defaultBranch = `an/${normalizedName}`

  let branchName = argv.branch?.trim() || defaultBranch
  initialPrompt = argv.prompt?.trim() || undefined

  if (!argv.branch && !argv.prompt) {
    const { branch: branchInput, harness: harnessInput, initialPrompt: promptInput } = await prompts([
      {
        type: 'text',
        name: 'branch',
        message: 'Branch name (esc for default)',
        initial: defaultBranch
      },
      {
        type: 'select',
        name: 'harness',
        message: 'Harness',
        choices: [
          { title: 'Claude Code', value: 'claude' },
          { title: 'OpenCode', value: 'opencode' },
          { title: 'Shell', value: 'shell' }
        ],
        initial: 0
      },
      {
        type: 'text',
        name: 'initialPrompt',
        message: 'Initial prompt (esc to skip)'
      }
    ])

    branchName = branchInput?.trim() || defaultBranch
    harness = harnessInput ?? 'claude'
    initialPrompt = promptInput?.trim() || undefined
  } else if (!argv.prompt) {
    const { initialPrompt: promptInput } = await prompts({
      type: 'text',
      name: 'initialPrompt',
      message: 'Initial prompt (esc to skip)'
    })
    initialPrompt = promptInput?.trim() || undefined
    harness = argv.harness || 'claude'
  } else {
    harness = argv.harness || 'claude'
  }

  // Check if branch already exists
  let branchExists = false
  try {
    await $`git rev-parse --verify ${branchName}`
    branchExists = true
  } catch { }

  console.log(`Creating worktree: ${worktreePath}`)
  console.log(`Branch: ${branchName}`)

  await fs.ensureDir(parentDir)
  $.quiet = false
  if (branchExists) {
    await $`git worktree add ${worktreePath} ${branchName}`
  } else {
    await $`git worktree add -b ${branchName} ${worktreePath} ${baseBranch}`
  }
  $.quiet = true

  // Copy files from .worktree-setup
  const includesFile = `${repoRoot}/.worktree-setup`
  if (!fs.existsSync(includesFile)) {
    console.log('')
    console.log('Error: .worktree-setup not found')
    console.log('')
    console.log('This file lists paths to copy into new worktrees (e.g. .env, node_modules).')
    console.log(`Create it at: ${includesFile}`)
    console.log('')
    console.log('Example contents:')
    console.log('  .env')
    console.log('  .env.local')
    console.log('  $ pnpm install')
    console.log('')
    console.log(`To create an empty one: touch ${includesFile}`)
    process.exit(1)
  }

  const lines = fs.readFileSync(includesFile, 'utf-8')
    .split('\n')
    .map(line => line.trim())
    .filter(line => line && !line.startsWith('#'))

  const filesToCopy = lines.filter(line => !line.startsWith('$'))
  commands = lines.filter(line => line.startsWith('$')).map(line => line.slice(1).trim())

  if (filesToCopy.length > 0) {
    console.log('Copying files from .worktree-setup...')
    for (const pattern of filesToCopy) {
      if (pattern.includes('*')) {
        // Glob pattern - find matching paths
        const matches = await glob(pattern, { cwd: repoRoot, dot: true })
        for (const match of matches) {
          const srcPath = `${repoRoot}/${match}`
          const destPath = `${worktreePath}/${match}`
          console.log(`  Copying ${match}...`)
          await fs.ensureDir(path.dirname(destPath))
          await fs.copy(srcPath, destPath)
        }
        if (matches.length === 0) {
          console.log(`  Warning: no matches for ${pattern}`)
        }
      } else {
        // Direct path
        const srcPath = `${repoRoot}/${pattern}`
        if (fs.existsSync(srcPath)) {
          console.log(`  Copying ${pattern}...`)
          const destPath = `${worktreePath}/${pattern}`
          await fs.ensureDir(path.dirname(destPath))
          await fs.copy(srcPath, destPath)
        } else {
          console.log(`  Warning: ${pattern} not found, skipping`)
        }
      }
    }
  }

}

// Tmux integration
if (!insideTmux) {
  console.log('Error: Must be run inside tmux')
  process.exit(1)
}

const background = !!initialPrompt
const newWindowFlags = background ? ['-d'] : []

function harnessCmd() {
  if (harness === 'claude') return initialPrompt ? ['claude', initialPrompt] : ['claude']
  if (harness === 'opencode') return initialPrompt ? ['opencode', '--agent', 'plan', '--prompt', initialPrompt] : ['opencode', '--agent', 'plan']
  return []
}

const cmd = harnessCmd()
if (cmd.length > 0) {
  await $`tmux new-window ${newWindowFlags} -c ${worktreePath} -n ${windowName} ${cmd}`
} else {
  await $`tmux new-window ${newWindowFlags} -c ${worktreePath} -n ${windowName}`
}
await $`tmux split-window -d -h -t ${windowName}.0 -c ${worktreePath} -l 60% nvim`
await $`tmux split-window -d -v -t ${windowName}.1 -c ${worktreePath} -l 30%`

// Run setup commands in the terminal pane
if (commands.length > 0) {
  const setupCmd = commands.join(' && ')
  await $`tmux send-keys -t ${windowName}.2 -l ${setupCmd}`
  await $`tmux send-keys -t ${windowName}.2 Enter`
}

// Open lazygit in nvim when switching to existing worktree
if (command === 'switch') {
  await $`sleep 1 && tmux send-keys -t ${windowName}.1 Space g g`
}

console.log(`${background ? 'Started' : 'Switched to'} worktree: ${windowName}`)
