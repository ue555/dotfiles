local ok, which_key = pcall(require, "which-key")
if not ok then
  return
end

which_key.setup({})
which_key.add({
  { "<leader>f", group = "Find" },
  { "<leader>g", group = "Git" },
  { "<leader>l", group = "LSP" },
})
