-----------------------------------------------------------
-- Mason
-----------------------------------------------------------
return {

  -- ref: https://www.youtube.com/watch?v=4BnVeOUeZxc

  -- mason (for install pyright)
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
      },

      -- Users can check the installed language servers with :Mason.
      -- If Mason did not install Pyright (the Python language server),
      -- use :MasonInstall pyright to manually install it,
      -- and add C:\Users\user\AppData\Local\nvim-data\mason\bin to PATH.
    },
  },
}
