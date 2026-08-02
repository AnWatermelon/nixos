local M = {}

-- Baseline palette. Used as-is until matugen writes a generated one, and as the
-- base that a partial generated palette is merged over.
local fallback = {
  base00 = "#131313",
  base01 = "#1f1f1f",
  base02 = "#2a2a2a",
  base03 = "#919191",
  base04 = "#c6c6c6",
  base05 = "#e2e2e2",
  base06 = "#e2e2e2",
  base07 = "#e2e2e2",
  base08 = "#ffb4ab",
  base09 = "#f5b7b2",
  base0A = "#d5c0d6",
  base0B = "#f0b0ff",
  base0C = "#f5b7b2",
  base0D = "#f0b0ff",
  base0E = "#d5c0d6",
  base0F = "#93000a",
}

-- The nvim config lives in the Nix store and is read-only, so the generated
-- palette cannot live next to this file. matugen writes a Lua chunk returning a
-- base16 table here instead.
local generated = vim.fs.joinpath(vim.fn.stdpath("state"), "matugen", "base16.lua")

local function palette()
  local ok, colors = pcall(dofile, generated)
  if ok and type(colors) == "table" then
    return vim.tbl_extend("force", fallback, colors)
  end
  return fallback
end

function M.setup()
  require("base16-colorscheme").setup(palette())
end

local signal

-- Re-apply the theme when matugen signals an update. Registered at most once
-- per session: creating a new handle per update leaks a libuv signal watcher
-- and stacks duplicate handlers.
function M.watch()
  if signal then
    return
  end
  signal = vim.uv.new_signal()
  signal:start("sigusr1", vim.schedule_wrap(M.setup))
end

return M
