-----------------------------------------------------------
-- Functions (module pattern)
-- 全域名稱在末尾明確匯出，減少隱式污染
-----------------------------------------------------------

local M = {}

-- show infomation
function M.notify(message, level, title)
  level = level or "info"
  title = title or "my awesome plugin"
  vim.notify(message .. ' ', level, {title = title})
end

-- highlight more
function M.enhance_c_syntax()
  vim.cmd([[syn match defined "\v\w@<!(\u|_|r+[A-Z0-9])[A-Z0-9_]*\w@!"]])
  vim.cmd([[hi def link defined Type]])

  vim.cmd([[syn match globalVariable "\vg([A-Z][A-Za-z0-9_]+)+" ]])
  vim.cmd([[hi globalVariable ctermfg=217 guifg=#FF7FC9]])

  vim.cmd([[syn match privateVariable "\vp([A-Z][A-Za-z0-9_]+)+" ]])
  vim.cmd([[hi privateVariable ctermfg=217 guifg=#CDC1FF]])
end

-- binary
function M.binary_enter(num)
  num = num or '4'
  vim.cmd('%!xxd -e -g ' .. num)
end

function M.binary_exit()
  vim.cmd('%!xxd -r')
end

-- file path
function M.file_name()
  local file = vim.fn.expand('%:t')
  M.notify(file)
  vim.fn.setreg('*', file)
end

function M.file_name_and_local_path()
  local file_path = vim.fn.expand('%')
  M.notify(file_path)
  vim.fn.setreg('*', file_path)
end

function M.file_name_and_global_path()
  local file_path = vim.fn.expand('%:p')
  vim.fn.setreg('*', file_path)
  M.notify(file_path)
end

-- buffer
function M.buffer_close_hidden()
  for _, bufnr in ipairs(vim.fn.getbufinfo({loaded = true})) do
    if bufnr.windows[1] == nil then
      vim.cmd('silent! bd ' .. bufnr.bufnr)
    end
  end
end

-- print lua table
function M.print_lua_table(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      M.print_lua_table(v, indent + 1)
    else
      print(formatting .. tostring(v))
    end
  end
end

-- root check
function M.root_check(path)
  local rootFilePath = path .. '/.root'
  local success, _ = os.rename(rootFilePath, rootFilePath)
  if not success then
    M.notify('"' .. (vim.uv or vim.loop).fs_realpath(path) .. '" is not root', 'error')
    return false
  end
  return true
end

-- show command source
function M.show_command_source(cmd)
  vim.cmd('verbose command ' .. cmd)
end

-- vimrc
function M.my_vimrc()
  vim.cmd('silent! :e $MYVIMRC')
  vim.cmd('silent! cd ' .. vim.fn.expand('%:h'))
  M.notify("Edit my vimrc file !!!")
end

-----------------------------------------------------------
-- Applications and Plugins function
-----------------------------------------------------------
local alpha_vim_status_ok, _ = pcall(require, 'alpha')
local possession_status_ok, _ = pcall(require, 'possession')
local telescope_status_ok, _ = pcall(require, 'telescope')
local telescope_file_browser_status_ok, _ = pcall(require, 'telescope._extensions.file_browser')
local gui_font_resize_ok, _ = pcall(require, 'gui-font-resize')

function M.alpha_vim_quote()
  if alpha_vim_status_ok then
    M.notify(vim.g.my_quote)
    vim.fn.setreg('*', vim.g.my_quote)
  end
end

function M.telescope_session_browser()
  if telescope_status_ok and possession_status_ok then
    vim.cmd('silent! Telescope possession list')
  end
end

function M.telescope_file_browser(path)
  if telescope_status_ok and telescope_file_browser_status_ok then
    path = path or (vim.uv or vim.loop).cwd()
    vim.cmd('silent! cd ' .. vim.fn.expand(path))
    vim.cmd('silent! Telescope file_browser')
    M.notify('Searching in ' .. path)
  end
end

function M.lsp_gen_compile_commands()
  generate_compile_commands()
  M.notify("generating compile_commands.json ...")
end

function M.gui_font_resize_up()
  if gui_font_resize_ok then
    vim.cmd("GUIFontSizeUp")
    local _, guifont = pcall(function() return vim.o.guifont end)
    M.notify('GUI Font = ' .. guifont)
  end
end

function M.gui_font_resize_down()
  if gui_font_resize_ok then
    vim.cmd("GUIFontSizeDown")
    local _, guifont = pcall(function() return vim.o.guifont end)
    M.notify('GUI Font = ' .. guifont)
  end
end

function M.gui_font_resize_reset()
  if gui_font_resize_ok then
    vim.cmd("GUIFontSizeSet")
    local _, guifont = pcall(function() return vim.o.guifont end)
    M.notify('GUI Font = ' .. guifont)
  end
end

-----------------------------------------------------------
-- 匯出全域名稱（供 :lua 指令字串與其他模組直接呼叫）
-----------------------------------------------------------
_G.MyNotify                  = M.notify
_G.EnhanceCSyntax            = M.enhance_c_syntax
_G.BinaryEnter               = M.binary_enter
_G.BinaryExit                = M.binary_exit
_G.FileName                  = M.file_name
_G.FileNameAndLocalPath      = M.file_name_and_local_path
_G.FileNameAndGlobalPath     = M.file_name_and_global_path
_G.BufferCloseHidden         = M.buffer_close_hidden
_G.PrintLuaTable             = M.print_lua_table
_G.RootCheck                 = M.root_check
_G.ShowCommandSource         = M.show_command_source
_G.MyVIMRC                   = M.my_vimrc
_G.AlphaVimQuote             = M.alpha_vim_quote
_G.TelescopeSessionBrowser   = M.telescope_session_browser
_G.TelescopeFileBrowser      = M.telescope_file_browser
_G.LspGenCompileCommands     = M.lsp_gen_compile_commands
_G.GuiFontResizeUp           = M.gui_font_resize_up
_G.GuiFontResizeDown         = M.gui_font_resize_down
_G.GuiFontResizeReset        = M.gui_font_resize_reset

return M
