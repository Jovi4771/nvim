----------------------------------------------------------
-- Plugin: possession
-- url: https://github.com/jedrzejboczar/possession.nvim
----------------------------------------------------------
return {
  "jedrzejboczar/possession.nvim",
  lazy = false,

  init = function()
    vim.g.my_session_path = "D:\\qiaofei_liu\\nvim\\.cache\\nvim-sessions" -- TODO: userdefine
    vim.fn.mkdir(vim.g.my_session_path, 'p')
  end,

  opts = {
    session_dir  = "D:\\qiaofei_liu\\nvim\\.cache\\nvim-sessions", -- TODO: userdefine, must same as vim.g.my_session_path
    silent       = false,
    load_silent  = true,
    debug        = false,
    logfile      = false,
    prompt_no_cr = false,
    autosave = {
      current  = true,   -- or fun(name): boolean
      tmp      = false,  -- or fun(): boolean
      tmp_name = 'tmp',
      on_load  = false,
      on_quit  = true,
    },

    commands = {
      save    = 'PossessionSave',
      load    = 'PossessionLoad',
      close   = 'PossessionClose',
      delete  = 'PossessionDelete',
      show    = 'PossessionShow',
      list    = 'PossessionList',
      migrate = 'PossessionMigrate',
    },

    hooks = {
      before_save = function(name) return {} end,
      after_save  = function(name, user_data, aborted) end,
      before_load = function(name, user_data) return user_data end,
      after_load  = function(name, user_data)
        if #name > 0 then
          local title = '' .. name
          vim.cmd('silent set titlestring=' .. title)
          vim.cmd('silent set title titlestring')
        end
      end,
    },

    plugins = {
      close_windows = {
        hooks = {'before_save', 'before_load'},
        preserve_layout = true,  -- or fun(win): boolean
        match = {
          floating = true,
          buftype  = {},
          filetype = {},
          custom   = false,  -- or fun(win): boolean
          },
        },

      delete_hidden_buffers = {
        hooks = {
          'before_load',
          vim.o.sessionoptions:match('buffer') and 'before_save',
        },
        force = false,  -- or fun(buf): boolean
      },

      nvim_tree      = true,
      tabby          = true,
      dap            = true,
      delete_buffers = true,
    },
  },
}
