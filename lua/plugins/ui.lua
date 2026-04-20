-----------------------------------------------------------
-- UI Components
-- Combines: colorscheme + lualine + alpha-nvim
-----------------------------------------------------------

return {
  {
    "gruvbox-community/gruvbox",
    lazy = false,
    init = function()
      vim.g.gruvbox_italic = 0
      vim.g.gruvbox_bold = 1
      vim.g.gruvbox_underline = 0
      vim.o.background = "dark"
      vim.cmd("colorscheme gruvbox")
      vim.cmd("hi! link PreCondit GruvboxAquaBold")
      vim.cmd("highlight Comment ctermfg=73 guifg=#6CA6D4")
    end,
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      -- options
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        vim.o.statusline = " "
      else
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      vim.o.laststatus = vim.g.lualine_laststatus

      local function get_location()
        local navic_status_ok, navic = pcall(require, "nvim-navic")
        if navic_status_ok then
          local location = navic.get_location()
          return '%=' .. '%*' .. location .. '%*'
        else
          return ""
        end
      end

      local colors = {
        fg1    = '#282828',
        color2 = '#504945',
        fg2    = '#ddc7a1',
        color3 = '#32302f',
        color4 = '#8ac6f2',
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

      local options = {
        theme = my_theme,
        icons_enable = true,
        component_separators = { left = '', right = '<' },
        section_separators   = { left = '', right = '' },
        always_divide_middle = true,
        globalstatus = false,
        disabled_filetypes = {
          statusline = { 'alpha' },
          winbar = {
            "help", "startify", "dashboard", "packer", "neogitstatus",
            "NvimTree", "Trouble", "alpha", "lir", "Outline",
            "spectre_panel", "toggleterm",
          },
        },
        refresh = {
          statusline = 1000,
          tabline    = 1000,
          winbar     = 1000,
        }
      }

      local component_buffers = {
        'buffers',
        show_filename_only      = true,
        hide_filename_extension = true,
        show_modified_status    = true,
        symbols = {
          modified = ' ●',
          alternate_file = '',
          directory = '',
        },
      }

      return {
        options = options,
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'filename' },
          lualine_c = {},
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = { 'filename' },
          lualine_c = {},
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        tabline = {
          lualine_a = {},
          lualine_b = { component_buffers },
          lualine_c = {},
          lualine_x = { get_location },
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        inactive_winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy" },
      }
    end,
  },

  {
    "goolord/alpha-nvim",
    cmd = "Alpha",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { "<leader>qq", ":Alpha<CR>" },
    },
    opts = function()
      local dashboard = require('alpha.themes.dashboard')
      dashboard.section.header.val  = {
        " ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        " ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        " ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        " ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        " ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        " ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
      }
      dashboard.section.buttons.val = {
        dashboard.button('e', '📂   New File       ', ':ene <BAR> startinsert<CR>'),
        dashboard.button('o', '📚   Open Project   ', ':lua TelescopeSessionBrowser()<CR>'),
        dashboard.button('f', '🔍   Find File      ', ':lua TelescopeFileBrowser()<CR>'),
        dashboard.button('s', '🛠   Settings       ', ':lua MyVIMRC()<CR>'),
        dashboard.button('l', '🖨   LSP Server     ', ''),
        dashboard.button('i', '📥   Plugins Install', ':Lazy<CR>'),
        dashboard.button('u', '🔼   Plugins Update ', ':Lazy<CR>'),
        dashboard.button('q', '🚪   Quit           ', ':qa<CR>'),
      }
      dashboard.section.footer.val = function()
        local version = vim.version()
        local plugins_text =
        "          Neovim (" .. version.major .. '.' .. version.minor .. '.' .. version.patch .. ") Powered by LazyVim ...  "
        local fortune = require("alpha.fortune")()
        vim.g.my_quote = table.concat(fortune, '\n')
        return plugins_text .. '\n' .. vim.g.my_quote
      end
      dashboard.config.layout[1].val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }
      dashboard.config.layout[3].val = 3
      dashboard.config.opts.noautocmd = true
    end,
    config = function()
      require('alpha').setup(require'alpha.themes.dashboard'.config)
    end,
  },
}
