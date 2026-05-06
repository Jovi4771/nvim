-----------------------------------------------------------
-- AI Assistant Plugins
-----------------------------------------------------------

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    dependencies = {
        {
          ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
          "folke/snacks.nvim",
          opts = {
          input = {}, -- Enhances `ask()`
          picker = { -- Enhances `select()`
            actions = {
              opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    config = function()
      local opencode_cmd = 'opencode --port'
      ---@type snacks.terminal.Opts
      local snacks_terminal_opts = {
        win = {
          position = 'right',
          enter = false,
          on_win = function(win)
            -- Set up keymaps and cleanup for an arbitrary terminal
            require('opencode.terminal').setup(win.win)
          end,
        },
      }
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function()
            require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
          end,
          stop = function()
            require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts):close()
          end,
          toggle = function()
            require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
          end,
        },
      }

      vim.o.autoread = true -- Required for `opts.events.reload`

      vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
      vim.keymap.set({ "n", "x" }, "<leader>os", function() require("opencode").toggle() end, { desc = "Execute opencode action…" })
    end,
  }
}
