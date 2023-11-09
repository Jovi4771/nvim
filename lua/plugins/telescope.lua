-----------------------------------------------------------
-- Neovim Search Engine
-----------------------------------------------------------

return {
  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>ff",
        function() require("telescope.builtin").find_files() end,
        desc = "Find Files",
      },

      {
        "<leader>bb",
        function() require("telescope.builtin").buffers() end,
        desc = "Find Buffers",
      },

      {
        "<C-\\>a",
        function() require("telescope.builtin").live_grep() end,
        desc = "Find Strings",
      },

      {
        "<leader>fb",
        function() vim.cmd([[lua TelescopeFileBrowser()]]) end,
        desc = "File Browser",
      },

      {
        "<C-\\>t",
        function() vim.cmd([[Telescope grep_string]]) end,
      },
    },

    -- change some options
    opts = function()
      return {
        defaults = {
          -- layout_strategy = "horizontal",
          -- layout_config = { prompt_position = "top" },
          -- sorting_strategy = "ascending",
          winblend = 0,

          -- Default configuration for telescope goes here:
          -- config_key = value,
          mappings = {
            i = {
              -- map actions.which_key to <C-h> (default: <C-/>)
              -- actions.which_key shows the mappings for your picker,
              -- e.g. git_{create, delete, ...}_branch for the git_branches picker
              ["<esc>"] = require("telescope.actions").close,
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
            }
          },

          file_ignore_patterns = {
            ".git/",
            ".cache/",
            ".config/",
            ".metadata/",
            ".settings/",
            "%.mk",
            "%.d",
            "%.o",
            "%.exe",
            "%.txt",
            "%.bin",
            "%.project",
            "%.cproject",
            "dist",
            "output",
            "Debug",
            "compile_commands.json",
            "compile_flags.txt"
          },

          extensions = {
            -- Your extension configuration goes here:
            -- extension_name = {
            --   extension_config_key = value,
            -- }
            -- please take a look at the readme of the extension you want to configure

            file_browser ={
              theme = "ivy",
              -- disables netrw and use telescope-file-browser in its place
              hijack_netrw = true,
              mappings = {
                ["i"] = {
                  -- your custom insert mode mappings
                },
                ["n"] = {
                  -- your custom normal mode mappings
                },
              },
            },

            require("telescope").load_extension("file_browser"),
            require("telescope").load_extension("possession"),
          },
        },
      }
    end,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
}
