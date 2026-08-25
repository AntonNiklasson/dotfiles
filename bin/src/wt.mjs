#!/usr/bin/env zx

import { $, fs, glob, path, YAML } from 'zx'
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

if (!command || !['new', 'switch', 'rm', 'mv', 'warmup', 'refresh'].includes(command)) {
  console.log('')
  console.log('Usage:')
  console.log('  wt new [name] [--branch BRANCH] [--prompt PROMPT] [--harness claude|opencode|shell]  - Create a new worktree')
  console.log('  wt switch               - Switch to existing worktree')
  console.log('  wt rm [name...] [--yes] - Remove worktrees (picker when no names given, --yes skips confirm)')
  console.log('  wt mv [name] [new-name] - Rename a worktree and its tmux window')
  console.log('  wt warmup [path]        - Apply .worktree-setup.yml to an existing worktree (cwd by default)')
  console.log('  wt refresh              - Spawn tmux windows for worktrees that lack one')
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

async function resolveWorktreePath(name) {
  const wtPaths = (await $`git worktree list`).stdout.trim()
    .split('\n').slice(1) // skip main worktree
    .map(line => line.split(/\s+/)[0])
  // match exact dir name or the shorthand after the repo prefix (sana-ai--dx → dx)
  return wtPaths.find(p => path.basename(p) === name || path.basename(p) === `${repoName}--${name}`) ?? null
}

const SETUP_FILE = '.worktree-setup.yml'

const EXAMPLE_SETUP = `copy:
  - .env
  - .env.local

run:
  - pnpm install
`

function readWorktreeSetup() {
  const setupPath = `${repoRoot}/${SETUP_FILE}`
  if (!fs.existsSync(setupPath)) {
    console.log('')
    console.log(`Error: ${SETUP_FILE} not found`)
    console.log('')
    console.log('This file declares what to copy into new worktrees and what to run there.')
    console.log(`Create it at: ${setupPath}`)
    console.log('')
    console.log('Example contents:')
    console.log(EXAMPLE_SETUP.split('\n').map(l => `  ${l}`).join('\n'))
    process.exit(1)
  }

  let parsed
  try {
    parsed = YAML.parse(fs.readFileSync(setupPath, 'utf-8')) ?? {}
  } catch (err) {
    console.log(`Error: ${SETUP_FILE} is not valid YAML`)
    console.log(`  ${err.message}`)
    process.exit(1)
  }

  if (typeof parsed !== 'object' || Array.isArray(parsed)) {
    console.log(`Error: ${SETUP_FILE} must be a mapping with 'copy' and/or 'run' keys`)
    process.exit(1)
  }

  for (const [key, value] of Object.entries(parsed)) {
    if (!['copy', 'run'].includes(key)) {
      console.log(`  Warning: unknown key '${key}' in ${SETUP_FILE}, ignoring`)
    } else if (value != null && !Array.isArray(value)) {
      console.log(`Error: '${key}' in ${SETUP_FILE} must be a list`)
      process.exit(1)
    }
  }

  return {
    copy: (parsed.copy ?? []).map(String),
    run: (parsed.run ?? []).map(String)
  }
}

async function applyWorktreeSetup({ targetPath, runCommands }) {
  const { copy: filesToCopy, run: cmds } = readWorktreeSetup()

  if (filesToCopy.length > 0) {
    console.log(`Copying files from ${SETUP_FILE}...`)
    for (const pattern of filesToCopy) {
      if (pattern.includes('*')) {
        const matches = await glob(pattern, { cwd: repoRoot, dot: true })
        for (const match of matches) {
          const srcPath = `${repoRoot}/${match}`
          const destPath = `${targetPath}/${match}`
          console.log(`  Copying ${match}...`)
          await fs.ensureDir(path.dirname(destPath))
          await fs.copy(srcPath, destPath)
        }
        if (matches.length === 0) {
          console.log(`  Warning: no matches for ${pattern}`)
        }
      } else {
        const srcPath = `${repoRoot}/${pattern}`
        if (fs.existsSync(srcPath)) {
          console.log(`  Copying ${pattern}...`)
          const destPath = `${targetPath}/${pattern}`
          await fs.ensureDir(path.dirname(destPath))
          await fs.copy(srcPath, destPath)
        } else {
          console.log(`  Warning: ${pattern} not found, skipping`)
        }
      }
    }
  }

  // Trust the copied .envrc so setup commands and the pane shell pick it up
  if (fs.existsSync(`${targetPath}/.envrc`)) {
    try {
      await $`direnv allow ${targetPath}`
    } catch {
      console.log('  Warning: direnv allow failed')
    }
  }

  if (runCommands && cmds.length > 0) {
    console.log('Running setup commands...')
    $.quiet = false
    for (const c of cmds) {
      console.log(`  $ ${c}`)
      // sh has no direnv hook; direnv exec loads .envrc (no-op if absent)
      await $({ cwd: targetPath, stdio: 'inherit' })`direnv exec ${targetPath} sh -c ${c}`
    }
    $.quiet = true
  }

  return cmds
}

if (command === 'warmup') {
  let targetPath = argv._[1] ? path.resolve(argv._[1]) : process.cwd()
  if (!fs.existsSync(targetPath)) {
    console.log(`Error: ${targetPath} does not exist`)
    process.exit(1)
  }
  // direnv keys its allow-list on the resolved path
  targetPath = fs.realpathSync(targetPath)
  console.log(`Warming up worktree: ${targetPath}`)
  await applyWorktreeSetup({ targetPath, runCommands: true })
  process.exit(0)
}

async function refreshTmuxWindows() {
  const wtPaths = (await $`git worktree list`).stdout.trim()
    .split('\n')
    .map(line => line.split(/\s+/)[0])

  // A window belongs to a worktree when its first pane lives there — stray
  // panes cd'd into a worktree from another window don't count as coverage
  const paneLines = (await $`tmux list-panes -a -F ${'#{window_id} #{pane_index} #{pane_current_path}'}`).stdout.trim().split('\n')
  const windowRoots = new Map()
  for (const line of paneLines) {
    const [winId, paneIndex, ...rest] = line.split(' ')
    const panePath = rest.join(' ')
    const existing = windowRoots.get(winId)
    if (!existing || Number(paneIndex) < existing.index) {
      windowRoots.set(winId, { index: Number(paneIndex), path: panePath })
    }
  }

  const windowNames = new Map(
    (await $`tmux list-windows -a -F ${'#{window_id} #{window_name}'}`).stdout.trim()
      .split('\n').map(line => [line.split(' ')[0], line.split(' ').slice(1).join(' ')])
  )

  for (const [i, wtPath] of wtPaths.entries()) {
    // the main checkout's window is always "main"
    const name = i === 0 ? 'main' : path.basename(wtPath).replace(`${repoName}--`, '')
    const match = [...windowRoots.entries()].find(([, w]) => w.path === wtPath || w.path.startsWith(`${wtPath}/`))
    if (match) {
      const [winId] = match
      if (windowNames.get(winId) !== name) {
        await $`tmux rename-window -t ${winId} ${name}`
        console.log(`~ ${name} (window renamed)`)
      } else {
        console.log(`= ${name} (window exists)`)
      }
      continue
    }
    const winId = (await $`tmux new-window -d -P -F ${'#{window_id}'} -c ${wtPath} -n ${name}`).stdout.trim()
    await $`tmux split-window -d -h -t ${winId} -c ${wtPath} -l 60% nvim`
    await $`tmux split-window -d -v -t ${winId}.1 -c ${wtPath} -l 30%`
    console.log(`+ ${name} (window created)`)
  }
}

if (command === 'refresh') {
  if (!insideTmux) {
    console.log('Error: Must be run inside tmux')
    process.exit(1)
  }
  await refreshTmuxWindows()
  process.exit(0)
}

if (command === 'mv') {
  const fromArg = argv._[1]
  let sourcePath
  if (fromArg) {
    sourcePath = await resolveWorktreePath(fromArg)
    if (!sourcePath) {
      console.log(`Error: no worktree matching "${fromArg}"`)
      process.exit(1)
    }
  } else {
    sourcePath = await pickWorktree('Rename worktree: ', (_, i) => i > 0)
    if (!sourcePath) {
      console.log('No worktree selected')
      process.exit(0)
    }
  }

  const currentName = path.basename(sourcePath).replace(`${repoName}--`, '')
  let newName = argv._[2]
  if (!newName) {
    const response = await prompts({
      type: 'text',
      name: 'newName',
      message: `New name for "${currentName}"`,
      initial: currentName
    })
    newName = response.newName
  }

  const normalizedName = String(newName ?? '').trim().replace(/[^a-zA-Z0-9_-]/g, '-')
  if (!normalizedName) {
    console.log('Name required')
    process.exit(1)
  }
  // compare paths, not names: a worktree outside the <repo>--<name> convention
  // still moves when the name is kept
  const targetPath = `${parentDir}/${repoName}--${normalizedName}`
  if (targetPath === sourcePath) {
    console.log('Nothing to rename')
    process.exit(0)
  }
  if (fs.existsSync(targetPath)) {
    console.log(`Error: "${targetPath}" already exists`)
    process.exit(1)
  }

  const s = ora(`Renaming ${currentName} → ${normalizedName}...`).start()
  try {
    await $`git worktree move ${sourcePath} ${targetPath}`
  } catch (err) {
    s.fail(`Rename failed: ${(err.stderr || err.message || '').trim()}`)
    process.exit(1)
  }
  s.succeed(`Renamed ${currentName} → ${normalizedName}`)

  // direnv keys its allow-list on the path, so the moved worktree needs re-allowing
  if (fs.existsSync(`${targetPath}/.envrc`)) {
    try {
      await $`direnv allow ${targetPath}`
    } catch {
      console.log('  Warning: direnv allow failed')
    }
  }

  if (!insideTmux) {
    console.log('Not inside tmux, skipping window refresh')
    process.exit(0)
  }

  // Shells survive the move but keep a stale $PWD, which also leaves direnv
  // unloaded — only safe to fix in panes sitting at a prompt
  const paneLines = (await $`tmux list-panes -a -F ${'#{pane_id} #{pane_current_command} #{pane_current_path}'}`).stdout.trim().split('\n')
  for (const line of paneLines) {
    const [paneId, paneCommand, ...rest] = line.split(' ')
    const panePath = rest.join(' ')
    const base = [sourcePath, targetPath].find(p => panePath === p || panePath.startsWith(`${p}/`))
    if (!base) continue
    if (!['zsh', 'bash', 'fish', 'sh'].includes(paneCommand)) continue
    const suffix = panePath.slice(base.length)
    await $`tmux send-keys -t ${paneId} -l ${`cd ${targetPath}${suffix}`}`
    await $`tmux send-keys -t ${paneId} Enter`
  }

  // give tmux a beat to pick up the new pane paths before matching on them
  await new Promise(resolve => setTimeout(resolve, 300))
  await refreshTmuxWindows()
  process.exit(0)
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
  let selectedPaths
  const names = argv._.slice(1)
  if (names.length > 0) {
    selectedPaths = []
    for (const name of names) {
      const match = await resolveWorktreePath(name)
      if (!match) {
        console.log(`Error: no worktree matching "${name}"`)
        process.exit(1)
      }
      selectedPaths.push(match)
    }
  } else {
    selectedPaths = await pickWorktree('Remove worktrees (Tab to select): ', (_, i) => i > 0, { multi: true })
  }
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

      if (selectedPaths.length === 1 && !argv.yes) {
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

    if (argv.yes) {
      confirmedPaths.push(wtPath)
      continue
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

  commands = await applyWorktreeSetup({ targetPath: worktreePath, runCommands: false })
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

// Run setup commands in the terminal pane, one prompt line each so shell
// hooks (e.g. direnv) fire between them
for (const c of commands) {
  await $`tmux send-keys -t ${windowName}.2 -l ${c}`
  await $`tmux send-keys -t ${windowName}.2 Enter`
}

// Open lazygit in nvim when switching to existing worktree
if (command === 'switch') {
  await $`sleep 1 && tmux send-keys -t ${windowName}.1 Space g g`
}

console.log(`${background ? 'Started' : 'Switched to'} worktree: ${windowName}`)
