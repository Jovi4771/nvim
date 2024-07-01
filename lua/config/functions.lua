-----------------------------------------------------------
-- Functions
-----------------------------------------------------------
-- show infomation
function MyNotify(message, level, title)
  -- "info"
  -- "warn"
  -- "error"
  -- "debug"
  level = level or "info"  -- 如果 level 沒有傳入，則使用 "info" 等級
  title = title or "my awesome plugin"
  vim.notify(message .. ' ', level, {title = title})
end

-- highlight more
function EnhanceCSyntax()
  -- Highlight #Define
  vim.cmd([[syn match defined "\v\w@<!(\u|_|r+[A-Z0-9])[A-Z0-9_]*\w@!"]])
  vim.cmd([[hi def link defined Type]])

  -- Highlight global variable
  vim.cmd([[syn match globalVariable "\vg([A-Z][A-Za-z0-9_]+)+" ]])
  vim.cmd([[hi globalVariable ctermfg=217 guifg=#FF7FC9]])

  -- Highlight private variable
  vim.cmd([[syn match privateVariable "\vp([A-Z][A-Za-z0-9_]+)+" ]])
  vim.cmd([[hi privateVariable ctermfg=217 guifg=#CDC1FF]])
end

-- binary
function BinaryEnter(num)
  num = num or '4'
  vim.cmd(':%!xxd -e -g ' .. num)
end

function BinaryExit()
  vim.cmd('%!xxd -r')
end

-- file path
function FileName()
  local file = vim.fn.expand('%:t')
  MyNotify(file)
  vim.fn.setreg('*', file)
end

function FileNameAndLoaclPath()
  local file_path = vim.fn.expand('%')
  MyNotify(file_path)
  vim.fn.setreg('*', file_path)
end

function FileNameAndGlobalPath()
  local file_path = vim.fn.expand('%:p')
  vim.fn.setreg('*', file_path)
  MyNotify(file_path)
end

-- buffer
function BufferCloseHidden()
  for _, bufnr in ipairs(vim.fn.getbufinfo({loaded = true})) do
    if bufnr.windows[1] == nil then
      vim.cmd('silent! bd ' .. bufnr.bufnr)
    end
  end
end

-- print lua table
function PrintLuaTable(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      PrintLuaTable(v, indent + 1)
    else
      print(formatting .. tostring(v))
    end
  end
end

-- root check
function RootCheck(path)
  local rootFilePath = path .. '/.root'
  local success, _ = os.rename(rootFilePath, rootFilePath)
  if not success then
    MyNotify('"' .. vim.loop.fs_realpath(path) .. '" is not root', 'error')
    return false
  end
  return true -- is root
end

-- show command soruce
function ShowCommandSource(cmd)
  vim.cmd('verbose command ' .. cmd)
end

-- vimrc
function MyVIMRC()
  vim.cmd('silent! :e $MYVIMRC')
  vim.cmd('silent! cd '.. vim.fn.expand('%:h'))
  MyNotify("Edit my vimrc file !!!")
end


-----------------------------------------------------------
-- Applications and Plugins function
-----------------------------------------------------------
local alpha_vim_status_ok, _ = pcall(require, 'alpha')
local possession_status_ok, _ = pcall(require, 'possession')
local telescope_status_ok, _ = pcall(require, 'telescope')
local telescope_file_browser_status_ok, _ = pcall(require, 'telescope._extensions.file_browser')
local gut_font_resize_ok, _ = pcall(require, 'gui-font-resize')

-- alpha-nvim
function AlphaVimQuote()
  if alpha_vim_status_ok then
    MyNotify(vim.g.my_quote)
    vim.fn.setreg('*', vim.g.my_quote)
  end
end

-- telescope session browser
function TelescopeSessionBrowser()
  if telescope_status_ok and possession_status_ok then
    vim.cmd('silent! Telescope possession list')
  end
end

-- telescope file browser
function TelescopeFileBrowser(path)
  if telescope_status_ok and telescope_file_browser_status_ok then
    path = path or vim.loop.cwd()
    vim.cmd('silent! cd ' .. vim.fn.expand(path))
    vim.cmd('silent! Telescope file_browser')
    MyNotify('Searching in ' .. path)
  end
end

-- lsp generater
function LspGenCompileCommands()
  generate_compile_commands()
  MyNotify("generating compile_commands.json ...")
end

-- gui font resize
function GuiFontResizeUp()
  if gut_font_resize_ok then
    vim.cmd("GUIFontSizeUp")

    local _, guifont = pcall(function() return vim.api.nvim_get_option("guifont") end)
    MyNotify('GUI Font = ' .. guifont)
  end
end

function GuiFontResizeDown()
  if gut_font_resize_ok then
    vim.cmd("GUIFontSizeDown")

    local _, guifont = pcall(function() return vim.api.nvim_get_option("guifont") end)
    MyNotify('GUI Font = ' .. guifont)
  end
end

function GuiFontResizeReset()
  if gut_font_resize_ok then
    vim.cmd("GUIFontSizeSet")

    local _, guifont = pcall(function() return vim.api.nvim_get_option("guifont") end)
    MyNotify('GUI Font = ' .. guifont)
  end
end


