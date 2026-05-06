-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-----------------------------------------------------------
-- Neovim shortcuts
-----------------------------------------------------------

-- Clear search highlighting with <leader> and c
map('n', '<leader>c', ':nohl<CR>', { desc = 'Clear search highlight' })

-- Change split orientation
map('n', '<leader>tk', '<C-w>t<C-w>K', { desc = 'Split: vertical -> horizontal' })
map('n', '<leader>th', '<C-w>t<C-w>H', { desc = 'Split: horizontal -> vertical' })

-- Reload configuration without restart nvim
map('n', '<leader>rr', ':source $MYVIMRC<CR>', { desc = 'Reload $MYVIMRC' })

map('n', '<space>', '<nop>', { desc = 'Disable <space>' })
map('n', '<F2>', ':lua MyVIMRC()<CR>', { desc = 'Edit $MYVIMRC' })
map('n', 'o', 'ko<esc>', { desc = 'Insert line above, stay normal' })
map('n', 'I', 'i<space><esc>', { desc = 'Insert single space' })
map('n', '<leader>w', '<C-w>', { desc = 'Window prefix' })
map('n', '<A-Right>', '<C-w>5>', { desc = 'Resize window right' })
map('n', '<A-Left>',  '<C-w>5<', { desc = 'Resize window left' })
map('n', '<C-.>',     '<C-w>5>', { desc = 'Resize window right' })
map('n', '<C-,>',     '<C-w>5<', { desc = 'Resize window left' })
map('n', '<A-Up>',    '<C-w>3+', { desc = 'Resize window up' })
map('n', '<A-Down>',  '<C-w>3-', { desc = 'Resize window down' })

-- 系統剪貼簿（跨平台：Win 用 *、macOS / Linux 用 +）
local platform = require('utils.platform')
local reg = platform.clipboard_reg
map('v', '<leader>y', '"' .. reg .. 'y', { desc = 'Yank to system clipboard' })
map('n', '<leader>p', '"' .. reg .. 'p', { desc = 'Paste from system clipboard' })
map('v', '<leader>p', '"' .. reg .. 'p', { desc = 'Paste from system clipboard' })

map('n', '9y', '"9y',   { desc = 'Yank to register 9' })
map('n', '9p', '"9p',   { desc = 'Paste from register 9' })
map('n', '<C-z>', '<nop>', { desc = 'Disable <C-z>' })
map('n', 'vv', 'viw', { desc = 'Select inner word' })
map('n', '*',  '*``', { desc = 'Search word (keep cursor)' })
map('n', '<C-/>', 'i/*  */<ESC>2hi', { desc = 'Insert C comment' })
map('i', '<C-/>', '/*  */<ESC>2hi', { desc = 'Insert C comment' })
map('i', '<S-Tab>', '<C-d>', { desc = 'Outdent' })
map('n', 'q:', '<nop>', { desc = 'Disable q:' })
map('n', 'Q',  '<nop>', { desc = 'Disable Q' })
map('n', '<C-Right>', ':bnext<CR>', { desc = 'Next buffer' })
map('n', '<C-Left>',  ':bprevious<CR>', { desc = 'Previous buffer' })
