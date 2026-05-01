#!/usr/bin/env zx

import { $, fs } from 'zx'
import prompts from 'prompts'
import os from 'node:os'
import path from 'node:path'

$.quiet = true

const histfile = process.env.HISTFILE || path.join(os.homedir(), '.zsh_history')
const raw = fs.readFileSync(histfile, 'latin1')

// EXTENDED_HISTORY entries look like ": 1234567890:0;command"
// Multi-line commands escape newlines with a trailing backslash.
const lines = []
let buf = ''
for (const line of raw.split('\n')) {
  buf = buf ? buf + '\n' + line : line
  if (buf.endsWith('\\')) {
    buf = buf.slice(0, -1)
    continue
  }
  lines.push(buf)
  buf = ''
}

const self = 'copylast'
const cmds = lines
  .map(l => l.replace(/^: \d+:\d+;/, ''))
  .filter(l => l.length > 0 && l.trim().split(/\s+/)[0] !== self)

const seen = new Set()
const unique = []
for (const c of cmds.reverse()) {
  if (!seen.has(c)) {
    seen.add(c)
    unique.push(c)
  }
}

const { chosen } = await prompts({
  type: 'autocomplete',
  name: 'chosen',
  message: 'copy cmd',
  choices: unique.map(c => ({ title: c, value: c })),
  limit: 15,
  suggest: (input, choices) =>
    Promise.resolve(choices.filter(c => c.title.toLowerCase().includes(input.toLowerCase())))
})

if (!chosen) process.exit(0)

const { what } = await prompts({
  type: 'select',
  name: 'what',
  message: 'copy what?',
  choices: [
    { title: 'command', value: 'command' },
    { title: 'output', value: 'output' },
    { title: 'both', value: 'both' },
  ],
})
if (!what) process.exit(0)

let payload = chosen
if (what !== 'command') {
  const { sure } = await prompts({
    type: 'confirm',
    name: 'sure',
    message: `re-run \`${chosen}\` to capture output?`,
    initial: false,
  })
  if (!sure) process.exit(0)

  const merged = `(${chosen}) 2>&1`
  const result = await $`zsh -ic ${merged}`.nothrow()
  const output = result.stdout

  payload = what === 'output' ? output : `$ ${chosen}\n${output}`
}

await $`printf %s ${payload} | pbcopy`
console.log(`Copied ${what}`)
