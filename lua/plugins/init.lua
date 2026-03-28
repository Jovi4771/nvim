-- Plugin package manager configuration
-- Using lazy.nvim with functional grouping

return {
  { import = "plugins.lsp" },
  { import = "plugins.ui" },
  { import = "plugins.telescope" },
  { import = "plugins.tools" },
  { import = "plugins.ai" },
  { import = "plugins.misc" },
}
