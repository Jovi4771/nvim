--[[
    "                                                      ",
    "   ███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓ ",
    "   ██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒ ",
    "  ▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░ ",
    "  ▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██  ",
    "  ▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒ ",
    "  ░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░ ",
    "  ░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░ ",
    "     ░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░        ░  ",
    "           ░    ░  ░    ░ ░        ░   ░           ░  ",
--]]


-- Import Lua lazy module
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- set leader key to space
vim.g.mapleader = " "

-- setup lazy
require("lazy").setup({
  spec = {
    -- Import Lua plugins
    { import = "plugins" },
  },
})

-- Import Lua configuration
require("config/autocmds")
require("config/options")
require("config/functions")
require("config/keymaps")
require("utils/clangd")
require("utils/avante")

