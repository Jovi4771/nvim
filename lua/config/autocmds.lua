-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

-- Define autocommands with Lua APIs
-- See: h:api-autocmd, h:augroup

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

-- General settings:
--------------------

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' })
  end
})

-- Remove whitespace on save
augroup('TrimWhitespace', { clear = true })
autocmd('BufWritePre', {
  group = 'TrimWhitespace',
  pattern = '*',
  command = ":%s/\\s\\+$//e"
})

-- Don't auto commenting new lines
augroup('NoAutoComment', { clear = true })
autocmd('BufEnter', {
  group = 'NoAutoComment',
  pattern = '*',
  command = 'set fo-=c fo-=r fo-=o'
})

-- Settings for filetypes
--------------------------

-- Disable line length marker
augroup('setLineLength', { clear = true })
autocmd('Filetype', {
  group = 'setLineLength',
  pattern = { 'text', 'markdown', 'html', 'xhtml', 'javascript', 'typescript' },
  command = 'setlocal cc=0'
})

-- Set indentation to 2 spaces
augroup('setIndent', { clear = true })
autocmd('Filetype', {
  group = 'setIndent',
  pattern = { 'xml', 'html', 'xhtml', 'css', 'scss', 'javascript', 'typescript', 'yaml', 'lua' },
  command = 'setlocal shiftwidth=2 tabstop=2'
})

-- Set C highlight
augroup('syntaxHighlight', { clear = true })
autocmd({'BufEnter', 'BufLeave'}, {
  group   = 'syntaxHighlight',
  pattern = {'*.c', '*.h'},
  callback = function()
    EnhanceCSyntax()
  end
})

-- Disable :Man command
augroup('disableManCommand', { clear = true })
autocmd('Filetype', {
  group   = 'disableManCommand',
  pattern = {'*'},
  command = 'command! -nargs=+ Man :execute "echo """'
})

-- Terminal settings
---------------------

local terminalGroup = augroup('TerminalSettings', { clear = true })

-- Open a Terminal on the right tab
autocmd('CmdlineEnter', {
  group = terminalGroup,
  command = 'command! Term :botright vsplit term://$SHELL'
})

-- Enter insert mode when switching to terminal
autocmd('TermOpen', {
  group = terminalGroup,
  command = 'setlocal listchars= nonumber norelativenumber nocursorline',
})

autocmd('TermOpen', {
  group = terminalGroup,
  pattern = '*',
  command = 'startinsert'
})

-- Close terminal buffer on process exit
autocmd('BufLeave', {
  group = terminalGroup,
  pattern = 'term://*',
  command = 'stopinsert'
})

-- File Status settings
---------------------

local fileStatusGroup = augroup('FileStatus', { clear = true })

-- Auto-detect file change when user return
autocmd({'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI'}, {
  group = fileStatusGroup,
  pattern = '*',
  command = "if mode() != 'c' | checktime | endif"
})

-- Notify user the file was been changed
autocmd('FileChangedShellPost', {
  group = fileStatusGroup,
  pattern = '*',
  callback = function()
    MyNotify('File changed on disk. Buffer reloaded !!!', 'warn')
  end
})

-- Binary file handling
local bin_group = vim.api.nvim_create_augroup("Binary", { clear = true })

vim.api.nvim_create_autocmd({"BufReadPre"}, {
  pattern = "*.bin",
  group = bin_group,
  callback = function()
    vim.opt_local.binary = true
  end,
})

vim.api.nvim_create_autocmd({"BufReadPost"}, {
  pattern = "*.bin",
  group = bin_group,
  callback = function()
    if vim.opt_local.binary:get() then
      vim.cmd('%!xxd -e -g 4')
      vim.opt_local.filetype = "xxd"
      vim.opt_local.modified = false
    end
  end,
})

vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = "*.bin",
  group = bin_group,
  callback = function()
    if vim.opt_local.binary:get() then
      vim.cmd('%!xxd -r')
      vim.cmd('%!xxd -e -g 4')
      vim.cmd('%!xxd -r')
    end
  end,
})

vim.api.nvim_create_autocmd({"BufWritePost"}, {
  pattern = "*.bin",
  group = bin_group,
  callback = function()
    if vim.opt_local.binary:get() then
      vim.cmd('%!xxd -e -g 4')
      vim.opt_local.modified = false
    end
  end,
})
