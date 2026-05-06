-----------------------------------------------------------
-- Platform Utilities
-- 跨平台判斷與共用常數，避免 has('win32') 散落各處
-----------------------------------------------------------

local M = {}

M.is_win  = vim.fn.has("win32")  == 1 or vim.fn.has("win64") == 1
M.is_mac  = vim.fn.has("mac")    == 1 or vim.fn.has("macunix") == 1
M.is_unix = vim.fn.has("unix")   == 1 and not M.is_mac

-- 路徑分隔符
M.sep = M.is_win and "\\" or "/"

-- 預設 GUI 字型（依平台）
function M.default_guifont()
  if M.is_win then
    return "Consolas:h12"
  elseif M.is_mac then
    return "Menlo:h13"
  else
    return "monospace:h12"
  end
end

-- 系統剪貼簿暫存器（Win 慣用 *，*nix/Mac 慣用 +）
M.clipboard_reg = M.is_win and "*" or "+"

return M
