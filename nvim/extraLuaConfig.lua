vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()
vim.cmd("colorscheme tokyonight-night")

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
	end,
})

vim.filetype.add({ filename = { ["flake.lock"] = "json" } })

local Path = require("pathlib")

-- Setup lazy.nvim
require("lazy").setup({
	dev = {
		---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
		-- TODO: figure out how not to have this magic constant
		path = tostring(Path(vim.api.nvim_list_runtime_paths()[3]):parent()),
		-- path = vim.api.nvim_list_runtime_paths()[1] .. "/pack/myNeovimPackages/start/",
		---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
		patterns = {}, -- For example {"folke"}
		fallback = false, -- Fallback to git when local plugin doesn't exist
	},
	install = {
		-- Safeguard in case we forget to install a plugin with Nix
		missing = false,
	},
	performance = {
		reset_packpath = false,
		rtp = {
			reset = false,
		},
	},
	spec = {
		{
			"echasnovski/mini.nvim",
			dev = true,
			config = function()
				require("mini.statusline").setup({})
				require("mini.surround").setup({})
			end,
		},
		{
			"numToStr/comment.nvim",
			dev = true,
			config = function()
				require("Comment").setup()
			end,
		},
		{
			"folke/todo-comments.nvim",
			dev = true,
			config = function()
				require("todo-comments").setup({ signs = false })
			end,
		},
		{
			"lewis6991/gitsigns.nvim",
			dev = true,
			dependencies = { "MunifTanjim/nui.nvim", dev = true },
			config = function()
				require("gitsigns").setup({
					on_attach = function(bufnr)
						local gitsigns = require("gitsigns")

						local function map(mode, l, r, opts)
							opts = opts or {}
							opts.buffer = bufnr
							vim.keymap.set(mode, l, r, opts)
						end

						-- Navigation
						map("n", "]h", function()
							if vim.wo.diff then
								vim.cmd.normal({ "]h", bang = true })
							else
								gitsigns.next_hunk()
							end
						end)

						map("n", "[h", function()
							if vim.wo.diff then
								vim.cmd.normal({ "[h", bang = true })
							else
								gitsigns.prev_hunk()
							end
						end)

						-- Actions
						map("n", "<leader>hs", gitsigns.stage_hunk)
						map("n", "<leader>hr", gitsigns.reset_hunk)
						map("v", "<leader>hs", function()
							gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
						end)
						map("v", "<leader>hr", function()
							gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
						end)
						map("n", "<leader>hu", gitsigns.undo_stage_hunk)
						map("n", "<leader>hp", gitsigns.preview_hunk_inline)
						map("n", "<leader>td", gitsigns.toggle_deleted)

						-- Text object
						map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
					end,
				})
			end,
		},
		{
			"stevearc/conform.nvim",
			dev = true,
			config = function()
				require("conform").setup({
					format_on_save = true,
					formatters_by_ft = {
						nix = { "alejandra" },
						lua = { "stylua" },
						cpp = { "clang_format" },
						tex = { "latexindent" },
						rust = { "rustfmt" },
						python = { "black" },
						-- -- Conform will run multiple formatters sequentially
						-- python = { "isort", "black" },
						-- -- Use a sub-list to run only the first available formatter
						-- javascript = { { "prettierd", "prettier" } },
					},
				})

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
			end,
		},
		{
			"nvim-telescope/telescope.nvim",
			dev = true,
			dependencies = {
				{ "nvim-lua/plenary.nvim", dev = true },
				{ "nvim-telescope/telescope-live-grep-args.nvim", dev = true },
				{ "nvim-tree/nvim-web-devicons", dev = true },
			},
			config = function()
				local telescope_builtin = require("telescope.builtin")
				require("telescope").load_extension("live_grep_args")
				vim.keymap.set("n", "ff", telescope_builtin.find_files)
				-- vim.keymap.set("n", "fg", telescope_builtin.live_grep)
				vim.keymap.set("n", "fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
				-- TODO: find out why using this instead of the line above doesn't work
				-- vim.keymap.set("n", "fg", require("telescope").load_extension("live_grep_args").live_grep_args)
				vim.keymap.set("n", "fo", telescope_builtin.oldfiles)
				vim.keymap.set("n", "fw", telescope_builtin.grep_string)
				vim.keymap.set(
					"v",
					"ff",
					"y<ESC>:Telescope live_grep_args default_text=<c-r>0<CR>",
					{ noremap = true, silent = true }
				)

				local actions = require("telescope.actions")
				require("telescope").setup({
					defaults = {
						path_display = { "smart" },
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
			end,
		},
		{
			"neovim/nvim-lspconfig",
			dev = true,
			dependencies = {
				{ "j-hui/fidget.nvim", dev = true, opts = {} },
				{
					"folke/neodev.nvim",
					dev = true,
					config = function()
						require("neodev").setup({
							override = function(root_dir, library)
								library.enabled = true
								library.plugins = true
							end,
						})
					end,
				},
			},
			config = function()
				-- TODO: what do these do?
				-- local capabilities = vim.lsp.protocol.make_client_capabilities()
				-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
				require("lspconfig").clangd.setup({})
				require("lspconfig").pyright.setup({})
				require("lspconfig").nil_ls.setup({})
				require("lspconfig").lua_ls.setup({})
				require("lspconfig").texlab.setup({})
				require("lspconfig").rust_analyzer.setup({})

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
						map("<leader>rn", vim.lsp.buf.rename, "[R]e[N]ame")

						-- Opens a popup that displays documentation about the word under your cursor
						--  See `:help K` for why this keymap.
						map("K", vim.lsp.buf.hover, "Hover Documentation")
					end,
				})
			end,
		},
		{ -- Autocompletion
			"hrsh7th/nvim-cmp",
			dev = true,
			dependencies = {
				-- Snippet Engine & its associated nvim-cmp source
				{ "L3MON4D3/luasnip", dev = true },
				{ "saadparwaiz1/cmp_luasnip", dev = true },

				-- Adds other completion capabilities.
				--  nvim-cmp does not ship with all sources by default. They are split
				--  into multiple repos for maintenance purposes.
				{ "hrsh7th/cmp-nvim-lsp", dev = true },
				{ "hrsh7th/cmp-path", dev = true },
			},
			config = function()
				-- See `:help cmp`
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
					sources = { { name = "nvim_lsp" }, { name = "path" } }, -- TODO: try neodev/lazydev and luasnip
				})
			end,
		},
		{
			"folke/noice.nvim",
			dev = true,
			config = function()
				require("noice").setup({
					lsp = {
						-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
						override = {
							["vim.lsp.util.convert_input_to_markdown_lines"] = true,
							["vim.lsp.util.stylize_markdown"] = true,
							["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
						},
					},
					-- you can enable a preset for easier configuration
					presets = {
						bottom_search = true, -- use a classic bottom cmdline for search
						command_palette = true, -- position the cmdline and popupmenu together
						long_message_to_split = true, -- long messages will be sent to a split
						inc_rename = false, -- enables an input dialog for inc-rename.nvim
						lsp_doc_border = false, -- add a border to hover docs and signature help
					},
				})
			end,
		},
		{
			"rcarriga/nvim-notify",
			dev = true,
			opts = {},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			dev = true,
			config = function()
				require("nvim-treesitter.configs").setup({
					highlight = {
						enable = true,
					},
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
			end,
		},
		{ "github/copilot.vim", dev = true },
		{ "tpope/vim-fugitive", dev = true },
		{
			"folke/zen-mode.nvim",
			dev = true,
			dependencies = {
				{
					"folke/twilight.nvim",
					dev = true,
				},
			},
		},
	},
})
