-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
local function map(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-----------------------------------------------------------
-- Neovim shortcuts
-----------------------------------------------------------

-- Disable arrow keys
--map('', '<up>', '<nop>')
--map('', '<down>', '<nop>')
--map('', '<left>', '<nop>')
--map('', '<right>', '<nop>')

-- Map Esc to kk
--map('i', 'kk', '<Esc>')

-- Clear search highlighting with <leader> and c
map('n', '<leader>c', ':nohl<CR>')

-- Toggle auto-indenting for code paste
map('n', '<F3>', ':set invpaste paste?<CR>')
vim.opt.pastetoggle = '<F3>'

-- Change split orientation
map('n', '<leader>tk', '<C-w>t<C-w>K') -- change vertical to horizontal
map('n', '<leader>th', '<C-w>t<C-w>H') -- change horizontal to vertical

-- Move around splits using Ctrl + {h,j,k,l}
--map('n', '<C-h>', '<C-w>h')
--map('n', '<C-j>', '<C-w>j')
--map('n', '<C-k>', '<C-w>k')
--map('n', '<C-l>', '<C-w>l')

-- Reload configuration without restart nvim
map('n', '<leader>rr', ':so $MYVIMRC<CR>')

-- Fast saving with <leader> and s
--map('n', '<leader>s', ':w<CR>')

-- Close all windows and exit from Neovim with <leader> and q
--map('n', '<leader>q', ':qa!<CR>')

map('n', '<space>', '<nop>')
map('n', '<F2>', ':lua MyVIMRC()<CR>')
map('n', 'o',  'ko<esc>')
map('n', 'I', 'i<space><esc>')
map('n', '<leader>w', '<C-w>')
map('n', '<A-Left', '<C-w>5>')
map('n', '<A-Right>', '<C-w>5<')
map('n', '<A-Up>', '<C-w>3+')
map('n', '<A-Down>', '<C-w>3-')
--if vim.fn.has("win32") then
map('v', '<leader>y', '"*y')
map('n', '<leader>p', '"*p')
map('v', '<leader>p', '"*p')
--end
map('n', '9y', '"9y')
map('n', '9p', '"9p')
--map('n', '0p', '"0p')
map('n', '<C-z>', '<nop>')
map('n', 'vv', 'viw')
map('n', '<leader>rr', ':source $MYVIMRC<CR>')
map('n', '*', '*``')
map('n', '<C-/>', 'i/*  */<ESC>2hi')
map('i', '<C-/>', '/*  */<ESC>2hi')
map('i', '<S-Tab>', '<C-d>')
map('n', 'q:', '<nop>')
map('n', 'Q', '<nop>')
map('n', '<C-Right>', ':bnext<CR>')
map('n', '<C-Left>', ':bNext<CR>')


-----------------------------------------------------------
-- Applications and Plugins shortcuts
-----------------------------------------------------------
--:echo @%                |" directory/name of file
--:echo expand('%:t')     |" name of file ('tail')
--:echo expand('%:p')     |" full path
--:echo expand('%:p:h')   |" directory containing file ('head')

