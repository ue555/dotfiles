-- nvpm currently installs plugins in this fixed path on every supported OS.
local nvpm_root = vim.fn.expand("~/.local/share/nvim/nvpm")

if vim.fn.isdirectory(nvpm_root) == 0 then
  vim.notify(
    "nvpm plugin directory was not found. Run `nvpmctl install`.",
    vim.log.levels.WARN
  )
  return
end

local plugins = vim.fn.glob(nvpm_root .. "/*", false, true)
table.sort(plugins)

for _, plugin_path in ipairs(plugins) do
  if vim.fn.fnamemodify(plugin_path, ":t") ~= "cache" then
    vim.opt.runtimepath:append(plugin_path)

    local after_path = plugin_path .. "/after"
    if vim.fn.isdirectory(after_path) == 1 then
      vim.opt.runtimepath:append(after_path)
    end
  end
end
