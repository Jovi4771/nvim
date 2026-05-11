-----------------------------------------------------------
-- LSP Configuration
-- Combines: nvim-lspconfig + mason
-----------------------------------------------------------

return {
  {
    "neovim/nvim-lspconfig",
    event = { "VimEnter" },
    init = function()
      vim.lsp.enable("clangd")
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--compile-commands-dir=build"
        },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".root",
          ".git"
        },
      })

      vim.lsp.enable("lua_ls")
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
      vim.lsp.enable("pyright")
    end,

    config = function()
      -- disable log
      -- Levels by name: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF"
      vim.lsp.log.set_level("OFF")

      -- clangd diagnostic filter
      local ignored_clangd_diagnostics = {
        -- ["-Wunused-variable"] = true,
        -- ["clang-diagnostic-unused-variable"] = true,
        -- ["readability-magic-numbers"] = true,
      }

      local publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
      vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        local client = vim.lsp.get_client_by_id(ctx.client_id)

        if client and client.name == "clangd" and result and result.diagnostics then
          result.diagnostics = vim.tbl_filter(function(diagnostic)
            local code = diagnostic.code
            if type(code) == "table" then
              code = code.value
            end

            return not ignored_clangd_diagnostics[code]
          end, result.diagnostics)
        end

        return publish_diagnostics(err, result, ctx, config)
      end

      -- Hide all semantic highlights
      for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
      end

      -- 全域禁用內建 Tag，防止沒 LSP 時按到噴紅字 (E433)
      vim.keymap.set('n', '<C-]>', '<nop>')

      -- 設定 LSP Attach 自動指令
      local fidget_ok, fidget = pcall(require, "fidget")

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          if client and client.server_capabilities.definitionProvider then
            vim.keymap.set('n', '<C-]>', function()
              local word = vim.fn.expand('<cword>')

              if fidget_ok then
                local handle = fidget.progress.handle.create({
                  title = "LSP Searching...",
                  message = "Finding definition of '" .. word .. "'",
                  lsp_client = { name = client.name },
                })

                local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

                client.request('textDocument/definition', params, function(err, result, ctx, _)
                  handle:finish()

                  if err then
                    fidget.notify("LSP Error: " .. err.message, vim.log.levels.ERROR)
                    return
                  end

                  if not result or vim.tbl_isempty(result) then
                    fidget.notify("No definition found for '" .. word .. "'", vim.log.levels.WARN)
                    return
                  end

                  local location = vim.islist(result) and result[1] or result
                  vim.lsp.util.show_document(location, client.offset_encoding, { focus = true })
                end, ev.buf)
              else
                local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
                client.request('textDocument/definition', params, function(err, result, _, _)
                  if err then
                    vim.notify("LSP Error: " .. err.message, vim.log.levels.ERROR)
                    return
                  end
                  if not result or vim.tbl_isempty(result) then
                    vim.notify("No definition found for '" .. word .. "'", vim.log.levels.WARN)
                    return
                  end
                  local location = vim.islist(result) and result[1] or result
                  vim.lsp.util.show_document(location, client.offset_encoding, { focus = true })
                end, ev.buf)
              end
            end, { buffer = ev.buf, desc = "LSP Jump (English UI)" })
          end
        end,
      })

      -- Diagnostic hover on CursorHold
      vim.api.nvim_create_autocmd("CursorHold", {
        group = vim.api.nvim_create_augroup("LspDiagnosticHover", { clear = true }),
        callback = function()
          require('clean-diagnostic').show()
        end,
      })
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      handlers = {},
    },
  },

  {
    "kurama622/clean-diagnostic",
    event = "LspAttach",
    init = function()
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "❌",
            [vim.diagnostic.severity.WARN] = "⚠️",
            [vim.diagnostic.severity.INFO] = "ℹ️",
            [vim.diagnostic.severity.HINT] = "💡",
          },
        },
      })
    end,
    opts = {
      icons = {
        "❌",   -- error  🔴
        "⚠️",   -- warn   🟠
        "ℹ️",   -- info   🔵
        "💡"    -- hint   🟢
      },
      border = "rounded",
      min_severity = 4,
      max_width = 78,
    },
    --keys = {
    --  {
    --    "<leader>sd",
    --    "<cmd>lua require('clean-diagnostic').show()<cr>",
    --    desc = "show the diagnostic of the current line",
    --  },
    --},
  }
}
