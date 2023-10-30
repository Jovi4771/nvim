-----------------------------------------------------------
-- Plugin: alpha-nvim
-- url: https://github.com/goolord/alpha-nvim
-----------------------------------------------------------
return
{
  "goolord/alpha-nvim",
  cmd = "Alpha",
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  keys = {
    {
      "<leader>qq",
      ":Alpha<CR>",
    },
  },

  opts = function()
    -- logo
    local dashboard = require('alpha.themes.dashboard')
    dashboard.section.header.val  = {
      " ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      " ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
      " ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
      " ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      " ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
      " ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    }

    -- button
    dashboard.section.buttons.val = {
      dashboard.button('e', '📂   New File       ', ':ene <BAR> startinsert<CR>'),
      dashboard.button('o', '📚   Open Project   ', ':lua TelescopeSessionBrowser()<CR>'),
      dashboard.button('f', '🔍   Find File      ', ':lua TelescopeFileBrowser()<CR>'),
      dashboard.button('s', '🛠   Settings       ', ':lua MyVIMRC()<CR>'),
      dashboard.button('l', '🖨   LSP Server     ', ''), -- :Mason<CR>
      dashboard.button('i', '📥   Plugins Install', ':Lazy<CR>'),
      dashboard.button('u', '🔼   Plugins Update ', ':Lazy<CR>'),
      dashboard.button('q', '🚪   Quit           ', ':qa<CR>'),
    }

    -- footer
    dashboard.section.footer.val = function()
      -- plugins_text
      local version = vim.version()
      local plugins_text =
      "          Neovim (" .. version.major .. '.' .. version.minor .. '.' .. version.patch .. ") Powered by LazyVim ...  "

      -- quote
      local fortune = require("alpha.fortune")()
      vim.g.my_quote = table.concat(fortune, '\n')
      --vim.fn.setreg('*', vim.g.my_quote) -- copy to clipboard

      return plugins_text .. '\n' .. vim.g.my_quote
    end

    -- config
    dashboard.config.layout[1].val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }
    dashboard.config.layout[3].val = 3
    dashboard.config.opts.noautocmd = true
  end,

  config = function()
      require('alpha').setup(require'alpha.themes.dashboard'.config)
  end
}

