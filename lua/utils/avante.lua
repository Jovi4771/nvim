function AvantePromptGenerate(root)
  root = root or vim.fn.getcwd()
  local filename = vim.fn.getcwd() .. "/avante.md"
  local content =
[[
# Avante System Prompt
請以繁體中文回答所有問題，並保持技術術語準確。
如果需要解釋程式碼，請使用繁體中文描述，並保留原始程式碼格式。
]]

  local sep = (function()
    if jit then
      local os = string.lower(jit.os)
      if os ~= 'windows' then
        return '/'
      else
        return '\\'
      end
    else
      return package.config:sub(1, 1)
    end
  end)()

  -- generate avante.md if not exist
  local file = io.open(root .. sep .. 'avante.md', 'r')
  if file then
    -- skip
    file:close()
  else
    local file = io.open(root .. sep .. 'avante.md', 'w+')
    file:write(content)
    file:close()
  end

  vim.notify("已生成 avante.md -> " .. filename, vim.log.levels.INFO)

end
