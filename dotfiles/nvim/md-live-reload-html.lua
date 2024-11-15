local function writeToFile(path, content)
	mymd2htmlfile = io.open(path, "w")
	mymd2htmlfile:write(content)
	mymd2htmlfile:flush()
	mymd2htmlfile:close()
end

local function currentFileContent()
	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

local function callProcess(cmdline)
	local handle = io.popen("mdtohtml " .. vim.fn.expand("%:p"), "r")
	if handle == nil then
		error("ERROR command " .. cmdline .. " failed to execute")
		return
	end
	handle:flush()
	str = handle:read("*a")
	handle:close()
	return str
end

local handle = nil
local function startPythonServer()
	if handle == nil then
		handle = io.popen("python3 -m http.server 8000 -d /tmp")
		if handle ~= nil then
			vim.api.nvim_create_autocmd({ "QuitPre" }, {
				callback = function()
					handle:close()
				end,
			})
		end
	end
end

local function liveReloadHtml()
	local html = callProcess("mdtohtml " .. vim.fn.expand("%:p"))
	if html == nil then
		error("ERROR mdtohtml returned nil")
		return
	end

	writeToFile(
		"/tmp/index.html",
		[[ <!DOCTYPE html> <html> <head><script type="text/javascript" src="https://livejs.com/live.js"></script></head> <body> ]]
			.. html
			.. [[</body></html>]]
	)
	startPythonServer()
end

vim.api.nvim_create_user_command("LiveReloadHtml", function()
	-- vim.cmd("source md-live-reload-html.lua")
	vim.api.nvim_create_autocmd("BufWritePost", { pattern = vim.fn.expand("%:p"), callback = liveReloadHtml })
end, {})
