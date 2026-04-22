vim.cmd([[
  autocmd BufNewFile,BufRead * if getline(1) =~# '^#!/.*zx' | setfiletype typescript | endif
]])
