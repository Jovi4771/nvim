-----------------------------------------------------------
-- Plugin: lualine
-- url: https://github.com/nvim-lualine/lualine.nvim
----------------------------------------------------------

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,

  opts = function()
    -- status
    vim.o.laststatus = vim.g.lualine_laststatus

    -- winbar
    local function get_location()
      local navic_status_ok, navic = pcall(require, "nvim-navic")
      if navic_status_ok then
        local location = navic.get_location()
        return '%=' .. '%*' .. location .. '%*'
        --[[
        return "%#WinBarSeparator#"
          .. "%="
          .. ""
          .. "%*"
          .. "%#WinBarContext#" .. " " .. ">" .. " " .. location .. "%*"
          .. "%#WinBarSeparator#"
          .. "%*"
        --]]
      else
        return ""
      end
    end

    --------------------------
    -- theme
    --------------------------
    local colors = { -- sync gruvbox-material
      fg1    = '#282828',
      color2 = '#504945',
      fg2    = '#ddc7a1',
      color3 = '#32302f',
      --color4 = '#a89984',
      color4 = '#8ac6f2', -- modity to wombot
      color5 = '#7daea3',
      color6 = '#a9b665',
      color7 = '#d8a657',
      color8 = '#d3869b',
      color9 = '#ea6962',
    }

    local my_theme = {
      normal = {
        a = { fg = colors.fg1, bg = colors.color4, gui = 'bold' },
        b = { fg = colors.fg2, bg = colors.color2 },
        c = { fg = colors.fg2, bg = colors.color3 },
      },
      command  = { a = { fg = colors.fg1, bg = colors.color5, gui = 'bold' } },
      inactive = { a = { fg = colors.fg2, bg = colors.color2 } },
      insert   = { a = { fg = colors.fg1, bg = colors.color6, gui = 'bold' } },
      replace  = { a = { fg = colors.fg1, bg = colors.color7, gui = 'bold' } },
      terminal = { a = { fg = colors.fg1, bg = colors.color8, gui = 'bold' } },
      visual   = { a = { fg = colors.fg1, bg = colors.color9, gui = 'bold' } },
    }

    --------------------------
    -- options
    --------------------------
    local options = {
      --https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
      --theme = 'gruvbox-material',
      theme = my_theme,

      icons_enable = true,
      component_separators = { left = '', right = '<' },
      section_separators   = { left = '', right = '' }, -- 
      always_divide_middle = true,
      globalstatus = false,  -- only show statusline on active buffer
      disabled_filetypes = {
        statusline = {
          'alpha',
        },

        winbar = {
          "help",
          "startify",
          "dashboard",
          "packer",
          "neogitstatus",
          "NvimTree",
          "Trouble",
          "alpha",
          "lir",
          "Outline",
          "spectre_panel",
          "toggleterm",
        },
      },

      refresh = {                  -- sets how often lualine should refresh it's contents ()
        statusline = 1000,         -- The refresh option sets minimum time that lualine tries
        tabline    = 1000,         -- to maintain between refresh. It's not guarantied if situation
        winbar     = 1000          -- arises that lualine needs to refresh itself before this time
                                   -- it'll do it.

                                   -- Also you can force lualine's refresh by calling refresh function
                                   -- like require('lualine').refresh()
      }
    }

    --------------------------
    -- session component
    --------------------------
    local component_buffers = {
      'buffers',
      show_filename_only      = true, -- Shows shortened relative path when set to false.
      hide_filename_extension = true, -- Hide filename extension when set to true.
      show_modified_status    = true, -- Shows indicator when the buffer is modified.

      --[[
      mode = 0, -- 0: Shows buffer name
                -- 1: Shows buffer index
                -- 2: Shows buffer name + buffer index
                -- 3: Shows buffer number
                -- 4: Shows buffer name + buffer number

      max_length = vim.o.columns * 2 / 3, -- Maximum width of buffers component,
                                          -- it can also be a function that returns
                                          -- the value of `max_length` dynamically.
      filetype_names = {
        TelescopePrompt = 'Telescope',
        dashboard = 'Dashboard',
        packer = 'Packer',
        fzf = 'FZF',
        alpha = 'Alpha'
      }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )

      buffers_color = {
        -- Same values as the general color option can be used here.
        active = 'lualine_{section}_normal',     -- Color for active buffer.
        inactive = 'lualine_{section}_inactive', -- Color for inactive buffer.
      },
      --]]

      symbols = {
        modified = ' ●',       -- Text to show when the buffer is modified
        alternate_file = '',   -- Text to show to identify the alternate file
        directory = '',        -- Text to show when the buffer is a directory
      },
    }

    return {
      --------------------------
      -- setup
      --------------------------
      -- options
      options = options,

      -- sections
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'filename' },
        lualine_c = {},
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },

     -- inactive_sections
      inactive_sections = {
        lualine_a = {},
        lualine_b = { 'filename' },
        lualine_c = {},
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },

      -- tabline
      tabline = {
        lualine_a = {},
        lualine_b = { component_buffers },
        lualine_c = {},
        lualine_x = { get_location },
        lualine_y = {},
        lualine_z = {},
      },

      -- winbar
      winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },

      -- inactive_winbar
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },

      -- extensions
      extensions = { "neo-tree", "lazy" },
    }
  end,
}
