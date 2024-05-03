vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.cmd("colorscheme tokyonight-night")
require("todo-comments").setup({ signs = false })
require("gitsigns").setup({})
require("mini.statusline").setup({})

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
-- TODO: find out why using this instead of the line above doesn't work
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
	pickers = {
		colorscheme = {
			enable_preview = true,
		},
	},
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

local luasnip = require("luasnip")
luasnip.config.setup({})
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),

		-- Accept the completion.
		--  This will auto-import if your LSP supports it.
		--  This will expand snippets if the LSP sent a snippet.
		["<CR>"] = cmp.mapping.confirm({ select = true }),

		-- Manually trigger a completion from nvim-cmp.
		--  Generally you don't need this, because nvim-cmp will display
		--  completions whenever it has completion options available.
		["<C-space>"] = function(fallback)
			if cmp.visible() then
				cmp.mapping.close()(fallback)
			else
				cmp.mapping.complete({})(fallback)
			end
		end,

		-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
		--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
	}),
	sources = { { name = "nvim_lsp" }, { name = "path" } },
})
require("fidget").setup({})
require("neodev").setup({
	override = function(root_dir, library)
		library.enabled = true
		library.plugins = true
	end,
})
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<leader>l", -- set to `false` to disable one of the mappings
			node_incremental = "<leader>l",
			scope_incremental = false,
			node_decremental = "<leader>k",
		},
	},
})
require("lspconfig").clangd.setup({})
require("lspconfig").pyright.setup({})
require("lspconfig").lua_ls.setup({
	capabilities = capabilities,
})
require("lspconfig").nil_ls.setup({})

vim.diagnostic.config({
	virtual_text = { prefix = "" }, -- '' ''
	signs = false,
})

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

		-- Opens a popup that displays documentation about the word under your cursor
		--  See `:help K` for why this keymap.
		map("K", vim.lsp.buf.hover, "Hover Documentation")
	end,
})
vim.filetype.add({ filename = { ["flake.lock"] = "json" } })
