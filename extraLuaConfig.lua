vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
	end,
})

require("conform").setup({
	formatters_by_ft = {
		nix = { "nixfmt" },
		lua = { "stylua" },
		-- -- Conform will run multiple formatters sequentially
		-- python = { "isort", "black" },
		-- -- Use a sub-list to run only the first available formatter
		-- javascript = { { "prettierd", "prettier" } },
	},
})

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.nix",
--   callback = function(args)
--     require("conform").format({ bufnr = args.buf })
--   end,
-- })

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_fallback = false, range = range })
end, { range = true })

local telescope_builtin = require("telescope.builtin")
require("telescope").load_extension("live_grep_args")
vim.keymap.set("n", "ff", telescope_builtin.find_files)
-- vim.keymap.set("n", "fg", telescope_builtin.live_grep)
vim.keymap.set("n", "fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
-- TODO find out why using this instead of the line above doesn't work
-- vim.keymap.set("n", "fg", require("telescope").load_extension("live_grep_args").live_grep_args)
vim.keymap.set("n", "fo", telescope_builtin.oldfiles)
vim.keymap.set("n", "fw", telescope_builtin.grep_string)
vim.keymap.set("v", "ff", "y<ESC>:Telescope live_grep_args default_text=<c-r>0<CR>", { noremap = true, silent = true })

local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			n = {
				["k"] = actions.move_selection_next,
				["l"] = actions.move_selection_previous,
			},
		},
	},
})

-- require("lspconfig").clangd.setup({})
require("lspconfig").lua_ls.setup({
	settings = { Lua = { workspace = { library = { unpack(vim.api.nvim_get_runtime_file("", true)) } } } },
})
require("lspconfig").nil_ls.setup({})

-- TODO reenable this after making it's colorscheme not look ugly
vim.diagnostic.disable()

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		-- NOTE: Remember that Lua is a real programming language, and as such it is possible
		-- to define small helper and utility functions so you don't have to repeat yourself.
		--
		-- In this case, we create a function that lets us more easily define mappings specific
		-- for LSP related items. It sets the mode, buffer and description for us each time.
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Jump to the definition of the word under your cursor.
		--  This is where a variable was first declared, or where a function is defined, etc.
		--  To jump back, press <C-t>.
		map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

		-- Find references for the word under your cursor.
		map("fr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	end,
})
