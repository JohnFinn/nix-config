-- load standard vis module, providing parts of the Lua API
require("vis")

vis.events.subscribe(vis.events.INIT, function()
	-- Your global configuration options
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	-- Your per window configuration options e.g.
	-- vis:command('set number')
end)

local N = vis.modes.NORMAL
local V = vis.modes.VISUAL
local O = vis.modes.OPERATOR_PENDING

-- Remap movement (non-recursive)
vis:map(N, "j", "<Left>")
vis:map(N, "k", "<Down>")
vis:map(N, "l", "<Up>")
vis:map(N, ";", "<Right>")

vis:map(V, "j", "<Left>")
vis:map(V, "k", "<Down>")
vis:map(V, "l", "<Up>")
vis:map(V, ";", "<Right>")

vis:map(O, "j", "<Left>")
vis:map(O, "k", "<Down>")
vis:map(O, "l", "<Up>")
vis:map(O, ";", "<Right>")
