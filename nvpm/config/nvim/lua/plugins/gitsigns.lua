local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
  return
end

gitsigns.setup({
  on_attach = function(buffer)
    local function map(lhs, rhs, description)
      vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = description })
    end

    map("]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, "Next Git hunk")

    map("[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, "Previous Git hunk")

    map("<leader>gp", gitsigns.preview_hunk, "Preview Git hunk")
    map("<leader>gb", gitsigns.blame_line, "Blame current line")
  end,
})
