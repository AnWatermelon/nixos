-- Every plugin is already on the packpath courtesy of Nix, so load order here
-- is just "colours first, then the rest".
require("plugins.treesitter")
require("plugins.base16")
require("plugins.snacks")
require("plugins.mini")
require("plugins.flash")
require("plugins.whichkey")
