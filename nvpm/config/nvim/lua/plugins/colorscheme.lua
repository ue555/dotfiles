local ok, tokyonight = pcall(require, "tokyonight")
if not ok then
  return
end

tokyonight.setup({
  style = "moon",
  transparent = false,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
  },
})

vim.cmd.colorscheme("tokyonight")
