#!/usr/bin/env zx

import { $ } from 'zx'
import minimist from 'minimist'

$.quiet = true

const argv = minimist(process.argv.slice(3))
const sort = argv.sort || 'recency'

if (!['recency', 'alphabetical', 'tmux'].includes(sort)) {
  console.error(`Unknown sort: ${sort}. Use recency, alphabetical, or tmux.`)
  process.exit(1)
}

const current = (await $`tmux display-message -p '#S:#I'`).stdout.trim()

const raw = (await $`tmux list-windows -a -F '#{session_last_attached} #{session_name}:#{window_index} #{window_name} #{session_name}'`).stdout.trim()

let lines = raw.split('\n').map(line => {
  const [timestamp, target, name, session] = line.split(' ')
  return { timestamp: Number(timestamp), target, name, session }
}).filter(w => w.target !== current)

if (sort === 'recency') {
  lines.sort((a, b) => b.timestamp - a.timestamp)
} else if (sort === 'alphabetical') {
  lines.sort((a, b) => a.name.localeCompare(b.name))
}

for (const w of lines) {
  console.log(`${w.target};${w.name.padEnd(25)}${w.session}`)
}
