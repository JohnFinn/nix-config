-- hjkl
vim.api.nvim_command([[
	noremap ; l
	noremap l k
	noremap k j
	noremap j h
	noremap h ;

	noremap gk gj
	noremap gl gk

	nnoremap <C-W>; <C-W>l
	nnoremap <C-W>l <C-W>k
	nnoremap <C-W>k <C-W>j
	nnoremap <C-W>j <C-W>h
	nnoremap <C-W>h <C-W>;

	set tabstop=2 shiftwidth=2 expandtab
]]);

(function()
	local XDG_SESSION_TYPE = vim.fn.getenv("XDG_SESSION_TYPE")
	if XDG_SESSION_TYPE == "x11" then
		vim.o.clipboard = "unnamedplus"
	elseif XDG_SESSION_TYPE == "wayland" then
		vim.o.clipboard = "unnamed"
		vim.g.clipboard = {
			copy = {
				["+"] = "wl-copy",
				["*"] = "wl-copy",
			},
			paste = {
				["+"] = { "wl-paste", "--no-newline" },
				["*"] = { "wl-paste", "--no-newline" },
			},
		}
	end
end)()

-- TODO: make plugin out of it
vim.api.nvim_create_user_command("Watchexec", function(args)
	local function quote(s)
		return "'" .. s .. "'"
	end
	io.popen(
		"wezterm cli send-text --pane-id "
			.. io.popen("wezterm cli split-pane --cells 10"):read("*a"):sub(1, -2)
			.. " "
			.. quote("watchexec --watch " .. vim.fn.expand("%:p") .. " -- ")
	)
end, {})

vim.api.nvim_create_user_command("ShellArgsSplit", function()
	vim.cmd([[s/ --/  \\\r    &/g]]) -- <cmd>
end, { range = true })

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.neovide_cursor_trail_size = 0.2

vim.keymap.set({ "n", "x" }, "<leader>w", "<cmd>set wrap!<cr>")
vim.keymap.set({ "n", "x" }, "q]", "<cmd>cnext<cr>")
vim.keymap.set({ "n", "x" }, "q[", "<cmd>cprev<cr>")
vim.keymap.set(
	{ "n", "x" },
	"<leader>b",
	[[<cmd>:let @+ = "breakpoint set --file " . expand("%:t") . " --line " . line(".")<cr>]]
)

-- disabled help because of https://github.com/rmagatti/auto-session/issues/325
vim.o.sessionoptions = "blank,buffers,curdir,folds,tabpages,winsize,winpos,terminal,localoptions"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
	end,
})

vim.filetype.add({
	extension = { tfstate = "json", kbd = "commonlisp" },
	filename = { ["flake.lock"] = "json", [".envrc"] = "bash", ["todo.txt"] = "todotxt" },
	pattern = {
		[".*/templates/.*%.tpl"] = "helm",
		[".*/templates/.*%.ya?ml"] = "helm",
		-- ["helmfile.*%.ya?ml"] = "helm",
		["~/.kube/config"] = "yaml",
	},
})

local Path = require("pathlib")

vim.opt.rtp:prepend(require("nix_paths").lazypath)

require("lazy").setup({
	-- TODO: try out lazy's change detection
	dev = {
		---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
		-- TODO: figure out proper way of doing it like here https://nixalted.com/
		path = tostring(Path(vim.api.nvim_list_runtime_paths()[3]):parent()),
		---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
		patterns = {}, -- For example {"folke"}
		fallback = false, -- Fallback to git when local plugin doesn't exist
	},
	install = { missing = false }, -- Safeguard in case we forget to install a plugin with Nix
	performance = { reset_packpath = true, rtp = { reset = true } },
	---@type LazySpec
	spec = {
		{
			-- the colorscheme should be available when starting Neovim
			"Mofiqul/vscode.nvim",
			dev = true,
			lazy = false, -- make sure we load this during startup if it is your main colorscheme
			priority = 1000, -- make sure to load this before all the other start plugins
			config = function()
				local colors = require("vscode.colors").get_colors()
				require("vscode").setup({
					group_overrides = {
						FlashBackdrop = { fg = colors.vscGray },
						FlashLabel = { bg = "#fd0178" },
						DiagnosticUnnecessary = { fg = colors.vscGray },
						DapBreakpoint = { fg = colors.vscRed },
					},
				})
				vim.cmd("colorscheme vscode")
				vim.api.nvim_set_hl(
					0,
					"CurrentSelectionMatches",
					(function(hl_group)
						hl_group.bg = "#333333"
						return hl_group
					end)(vim.api.nvim_get_hl(0, { name = "Visual" }))
				)
			end,
		},
		{
			"aaron-p1/match-visual.nvim",
			dev = true,
			init = function() end,
			opts = { min_length = 5, hl_group = "CurrentSelectionMatches" },
			event = "ModeChanged *:[vV\x16]*",
		},
		{
			"stevearc/oil.nvim",
			dev = true,
			---@module 'oil'
			---@type oil.SetupOpts
			opts = {},
			cmd = "Oil",
			-- Optional dependencies
			-- dependencies = { { "echasnovski/mini.icons", opts = {} } },
			-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
		},
		{
			"nvim-tree/nvim-tree.lua",
			dev = true,
			config = function()
				require("nvim-tree").setup({ view = { side = "right" } })
				vim.api.nvim_create_autocmd({ "QuitPre" }, {
					callback = function()
						vim.cmd("NvimTreeClose")
					end,
				})
			end,
			cmd = { "NvimTreeFindFile" },
			keys = { { "<leader>tt", mode = { "n", "x" }, "<cmd>NvimTreeFindFile<cr>" } },
		},
		{
			"rmagatti/auto-session",
			dev = true,
			lazy = false,
			-- dependencies = {
			-- 	"nvim-telescope/telescope.nvim", -- Only needed if you want to use session lens
			-- },
			---enables autocomplete for opts
			---@module "auto-session"
			---@type AutoSession.Config
			opts = {
				-- NOTE: README has differentt name. Could be broken on update
				auto_session_suppress_dirs = { "~/", "~/code", "~/Downloads", "/" },
				-- log_level = 'debug',
			},
		},
		{
			"folke/flash.nvim",
			dev = true,
			---@type Flash.Config
			opts = {},
			-- stylua: ignore
			keys = {
				{ "ss", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
				{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
				{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
				{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
				{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
			},
		},
		{ "brenoprata10/nvim-highlight-colors", dev = true, opts = {}, event = "VeryLazy" },
		{
			"echasnovski/mini.nvim",
			dev = true,
			lazy = false, -- disables UI flickeriing in statusbar changing it's style
			config = function()
				require("mini.statusline").setup({
					content = {
						-- Content for active window
						active = function()
							local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
							local git = MiniStatusline.section_git({ trunc_width = 75, icon = "" })
							local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
							local filename = MiniStatusline.section_filename({ trunc_width = 140 })
							local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
							local location = MiniStatusline.section_location({ trunc_width = 75 })
							local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

							return MiniStatusline.combine_groups({
								{ hl = mode_hl, strings = { mode } },
								{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
								"%<", -- Mark general truncate point
								{ hl = "MiniStatuslineFilename", strings = { filename } },
								"%=", -- End left alignment
								{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
								{ hl = mode_hl, strings = { search, location } },
							})
						end,
						-- Content for inactive window(s)
						inactive = nil,
					},
				})
				-- MiniStatusline.section_git({ args })

				require("mini.surround").setup({
					custom_surroundings = { ["l"] = { output = { left = "[&](){return ", right = " ;}()" } } },
				})
			end,
		},
		{
			"numToStr/comment.nvim",
			dev = true,
			event = "VeryLazy",
			---@type CommentConfig
			opts = {},
		},
		{
			"folke/todo-comments.nvim",
			dev = true,
			event = "VeryLazy",
			opts = { signs = false },
		},
		{
			"lewis6991/gitsigns.nvim",
			dev = true,
			event = "VeryLazy",
			dependencies = { "MunifTanjim/nui.nvim", dev = true },
			init = function()
				-- fixes UI flickering when using gitsigns
				vim.api.nvim_command("set signcolumn=yes")
			end,
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
			event = { "BufWritePre" },
			cmd = { "ConformInfo", "Format" },
			config = function()
				require("conform").setup({
					-- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#command-to-toggle-format-on-save
					format_on_save = function(bufnr)
						-- Disable with a global or buffer-local variable
						if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
							return
						end
						return { timeout_ms = 1000, lsp_format = "never" }
					end,
					formatters_by_ft = {
						nix = { "alejandra" },
						lua = { "stylua" },
						cpp = { "clang_format" },
						tex = { "latexindent" },
						rust = { "rustfmt" },
						-- Use a sub-list to run only the first available formatter
						python = { "ruff_format" }, -- black
						-- markdown = { "mdformat" },
						terraform = { "tofufmt" },
						just = { "justfmt" },
						-- kotlin = { "ktfmt" },
						-- -- Conform will run multiple formatters sequentially
						-- python = { "isort", "black" },
						javascript = { { "prettierd", "prettier" } },
						java = { "spotless" },
						cmake = { "cmake_format" },
					},
					formatters = {
						tofufmt = { inherit = false, command = "tofu", args = { "fmt", "-" }, stdin = true },
						justfmt = {
							inherit = false,
							command = "just",
							args = { "--justfile", "$FILENAME", "--fmt", "--unstable" },
							stdin = false,
						},
						spotless = {
							inherit = false,
							command = "sh",
							args = { "-c", 'mvn spotless:apply -DspotlessFiles="$0"', "$FILENAME" },
							stdin = false,
						},
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
				vim.api.nvim_create_user_command("FormatDisable", function(args)
					if args.bang then
						-- FormatDisable! will disable formatting just for this buffer
						vim.b.disable_autoformat = true
					else
						vim.g.disable_autoformat = true
					end
				end, {
					desc = "Disable autoformat-on-save",
					bang = true,
				})
				vim.api.nvim_create_user_command("FormatEnable", function()
					vim.b.disable_autoformat = false
					vim.g.disable_autoformat = false
				end, {
					desc = "Re-enable autoformat-on-save",
				})
			end,
		},
		{
			"mfussenegger/nvim-lint",
			dev = true,
			enabled = false,
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				local lint = require("lint")

				lint.linters_by_ft = {
					javascript = { "eslint_d" },
					typescript = { "eslint_d" },
					javascriptreact = { "eslint_d" },
					typescriptreact = { "eslint_d" },
					svelte = { "eslint_d" },
					python = { "pylint" },
					yaml = { "yamllint" },
					dockerfile = { "hadolint" },
				}

				local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

				vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
					group = lint_augroup,
					callback = function()
						lint.try_lint()
					end,
				})

				vim.api.nvim_create_user_command("Lint", function()
					lint.try_lint()
				end, { desc = "Trigger linting for current file" })
			end,
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			dev = true,
			-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
			-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
			--stylua: ignore
			dependencies = { { "nvim-treesitter/nvim-treesitter", dev = true }, { "nvim-tree/nvim-web-devicons", dev = true }, }, -- if you prefer nvim-web-devicons
			ft = { "markdown" },
			---@module 'render-markdown'
			---@type render.md.UserConfig
			opts = {},
		},
		{
			"nvim-telescope/telescope.nvim",
			dev = true,
			event = "VeryLazy",
			dependencies = {
				{ "nvim-lua/plenary.nvim", dev = true },
				{ "nvim-telescope/telescope-live-grep-args.nvim", dev = true },
				{ "nvim-tree/nvim-web-devicons", dev = true },
			},
			config = function()
				-- TODO: install and test fzf extension
				local telescope_builtin = require("telescope.builtin")
				require("telescope").load_extension("live_grep_args")
				local TelescopeCaller = function(input)
					return function()
						input(require("telescope.themes").get_ivy({}))
					end
				end
				vim.keymap.set("n", "ff", TelescopeCaller(telescope_builtin.find_files))
				-- vim.keymap.set("n", "fg", telescope_builtin.live_grep)
				vim.keymap.set(
					"n",
					"fg",
					TelescopeCaller(require("telescope").load_extension("live_grep_args").live_grep_args)
				)
				vim.keymap.set("n", "fo", TelescopeCaller(telescope_builtin.oldfiles))
				vim.keymap.set("n", "fw", TelescopeCaller(telescope_builtin.grep_string))
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
						find_files = {
							hidden = true,
							find_command = { "rg", "--files", "--hidden", "--glob=!**/.git/*" },
						},
						colorscheme = { enable_preview = true },
					},
				})
			end,
		},
		{
			"neovim/nvim-lspconfig",
			dev = true,
			event = "VeryLazy",
			dependencies = {
				{ "j-hui/fidget.nvim", dev = true, opts = {} },
				{ -- TODO: replace with lazydev
					"folke/neodev.nvim",
					dev = true,
					---@type LuaDevOptions
					opts = {
						override = function(root_dir, library)
							library.enabled = true
							library.plugins = true
						end,
					},
				},
			},
			config = function()
				-- TODO: what do these do?
				-- local capabilities = vim.lsp.protocol.make_client_capabilities()
				-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
				require("lspconfig").clangd.setup({ --[[ cmd = { "clangd", "--log=verbose" } ]]
				})
				require("lspconfig").pyright.setup({})
				require("lspconfig").nixd.setup({
					cmd = { "nixd" },
					settings = {
						nixd = {
							nixpkgs = {
								expr = "import <nixpkgs> { }",
							},
							-- formatting = {
							-- 	command = { "alejandra" }, -- or nixfmt or nixpkgs-fmt
							-- },
							options = {
								--   nixos = {
								--       expr = '(builtins.getFlake "/PATH/TO/FLAKE").nixosConfigurations.CONFIGNAME.options',
								--   },
								home_manager = {
									expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."jouni".options',
								},
							},
						},
					},
				})
				require("lspconfig").lua_ls.setup({})
				require("lspconfig").texlab.setup({})
				require("lspconfig").rust_analyzer.setup({})
				require("lspconfig").ts_ls.setup({})
				require("lspconfig").jdtls.setup({})
				require("lspconfig").bashls.setup({})
				require("lspconfig").fish_lsp.setup({})
				require("lspconfig").jsonls.setup({})
				require("lspconfig").yamlls.setup({})
				require("lspconfig").dockerls.setup({})
				require("lspconfig").neocmake.setup({})
				require("lspconfig").terraformls.setup({})
				-- BUG: language server won't stop on vim exit. New server spawns on re-entry.
				-- this eventually leads to 100% RAM & CPU usage
				-- require("lspconfig").kotlin_language_server.setup({})

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

						map("<leader>hh", function()
							vim.cmd("ClangdSwitchSourceHeader")
						end, "Switch Source/Header (C/C++)")
					end,
				})
				-- NOTE: lsp won't work with initially opened file when loaded with VeryLazy, but would when switching files
				-- this workaround I came up with to make it work again. Maybe there is a better way
				vim.api.nvim_command("LspStart")
			end,
		},
		{ -- Autocompletion
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
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
					window = {
						documentation = cmp.config.window.bordered({
							winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
						}),
					},
					formatting = {
						fields = { "kind", "abbr" },
						format = function(_, vim_item)
							local cmp_kinds = {
								Text = "  ",
								Method = "󰡱  ",
								Function = "󰊕  ",
								Constructor = "  ",
								Field = "  ",
								Variable = "  ",
								Class = "  ",
								Interface = "  ",
								Module = "  ",
								Property = "  ",
								Unit = "  ",
								Value = "  ",
								Enum = "  ",
								Keyword = "  ",
								Snippet = "  ",
								Color = "  ",
								File = "  ",
								Reference = "  ",
								Folder = "  ",
								EnumMember = "  ",
								Constant = "  ",
								Struct = "  ",
								Event = "  ",
								Operator = "  ",
								TypeParameter = "  ",
							}
							vim_item.kind = cmp_kinds[vim_item.kind] or ""
							return vim_item
						end,
					},
				})
			end,
		},
		{
			"rcarriga/nvim-dap-ui",
			dev = true,
			dependencies = { { "mfussenegger/nvim-dap", dev = true }, { "nvim-neotest/nvim-nio", dev = true } },
			config = function()
				require("dapui").setup({
					layouts = {
						{
							elements = {
								{ id = "scopes", size = 0.25 },
								{ id = "breakpoints", size = 0.25 },
								{ id = "stacks", size = 0.25 },
								{ id = "watches", size = 0.25 },
							},
							position = "right",
							size = 40,
						},
						{
							elements = {
								{ id = "repl", size = 0.5 },
								{ id = "console", size = 0.5 },
							},
							position = "bottom",
							size = 10,
						},
					},
					mappings = {
						edit = "e",
						expand = { "<CR>", "<2-LeftMouse>" },
						open = "gd",
						remove = "d",
						repl = "r",
						toggle = "t",
					},
				})
				vim.api.nvim_create_autocmd("QuitPre", {
					desc = "Close dapui on :q",
					callback = function()
						require("dapui").close()
					end,
				})
			end,
			keys = {
				-- stylua: ignore
				{ "<leader>dui", mode = { "n", "x" }, function() require('dapui').toggle() end },
			},
		},
		{
			"mfussenegger/nvim-dap",
			dev = true,
			dependencies = {
				{
					"mfussenegger/nvim-dap-python",
					dev = true,
					config = function()
						require("dap-python").setup("python")
					end,
				},
			},
			init = function()
				vim.fn.sign_define("DapBreakpoint", {
					text = "",
					texthl = "DapBreakpoint",
				})
				-- TODO:
				-- vim.fn.sign_define('DapBreakpointCondition', { text='ﳁ', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint' })
				-- vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl= 'DapBreakpoint' })
				-- vim.fn.sign_define('DapLogPoint', { text='', texthl='DapLogPoint', linehl='DapLogPoint', numhl= 'DapLogPoint' })
				-- vim.fn.sign_define('DapStopped', { text='', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })
			end,
			config = function()
				local dap = require("dap")
				dap.adapters.gdb = {
					type = "executable",
					command = "gdb",
					args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
				}
				dap.adapters.codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						-- CHANGE THIS to your path!
						command = require("nix_paths").codelldb,
						args = { "--port", "${port}" },

						-- On windows you may have to uncomment this:
						-- detached = false,
					},
				}
				dap.adapters.lldb = {
					type = "executable",
					command = require("nix_paths").lldb_dap, -- adjust as needed, must be absolute path
					name = "lldb",
				}
			end,
			-- stylua: ignore
			keys = {
				{ "<leader>db", mode = { "n", "x" }, function() require('dap').toggle_breakpoint() end, desc = "Toggle breakpoint" },
				{ "<leader>dc", mode = { "n", "x" }, function() require('dap').continue() end, desc = "Debug continue" },
				{ "<leader>dj", mode = { "n", "x" }, function() require('dap').up() end, desc = "Debug callstack up" },
				{ "<leader>d;", mode = { "n", "x" }, function() require('dap').down() end, desc = "Debug callstack down" },
			},
		},
		{
			"ThePrimeagen/refactoring.nvim",
			dev = true,
			dependencies = {
				{ "nvim-lua/plenary.nvim", dev = true },
				{ "nvim-treesitter/nvim-treesitter", dev = true },
			},
			opts = {},
			keys = {
				{ "<leader>ri", mode = { "n", "x" }, "<cmd>Refactor inline_var<cr>", desc = "Refactor Inline" },
			},
		},
		{
			"folke/noice.nvim",
			dev = true,
			enabled = false, -- TODO: reanable. Was disabled because it makes dap prompts unusable
			lazy = false, -- disables UI flickering in statusbar movement one line below
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
			event = "VeryLazy",
			opts = {},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			dev = true,
			event = "VeryLazy",
			dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", dev = true },
			config = function()
				require("nix_paths").load_treesitters()
				---@diagnostic disable-next-line: missing-fields
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
					textobjects = {
						swap = {
							enable = true,
							swap_next = {
								["<leader>sw"] = "@parameter.inner",
								["<leader>sf"] = "@function.outer",
							},
						},
						move = {
							enable = true,
							set_jumps = true,
							goto_next_start = {
								["]w"] = "@parameter.inner",
								["]f"] = "@function.outer",
							},
							goto_previous_start = {
								["[w"] = "@parameter.inner",
								["[f"] = "@function.outer",
							},
						},
					},
				})
			end,
		},
		{ "github/copilot.vim", dev = true },
		{
			"yetone/avante.nvim",
			dev = true,
			opts = {},
			cmd = "AvanteAsk",
		},
		{ "tpope/vim-fugitive", dev = true, event = "VeryLazy" },
		{ "tpope/vim-rhubarb", dev = true, event = "VeryLazy" },
		{
			"folke/zen-mode.nvim",
			dev = true,
			cmd = "ZenMode",
			keys = {
				{ "Z", "<cmd>ZenMode<cr>", desc = "ZenMode" },
				{ "z", "<cmd>Twilight<cr>", desc = "Twilight" },
			},
			dependencies = { { "folke/twilight.nvim", dev = true } },
			opts = {
				plugins = {
					wezterm = {
						enabled = true,
						font = "+2",
					},
				},
			},
		},
		{ "glacambre/firenvim", build = ":call firenvim#install(0)", dev = true, enabled = false },
		{
			"LintaoAmons/bookmarks.nvim",
			dev = true,
			cmd = { "BookmarksMark", "BookmarksGoto", "BookmarksNewList", "BookmarksLists", "BookmarksCommands" },
			dependencies = {
				{ "kkharji/sqlite.lua", dev = true },
				{ "nvim-telescope/telescope.nvim", dev = true },
				-- { "stevearc/dressing.nvim" }, -- optional: better UI
			},
			config = function()
				local opts = {} -- check the "./lua/bookmarks/default-config.lua" file for all the options
				require("bookmarks").setup(opts) -- you must call setup to init sqlite db
			end,
		},
	},
})

if vim.g.exitAfterStart then
	vim.api.nvim_create_autocmd("User", {
		pattern = "LazyVimStarted", -- TODO: find out if "LazyDone" is a better choice
		desc = "tool for benchmarking startup time. To use run vim --cmd 'let g:exitAfterStart=1'",
		callback = function()
			vim.api.nvim_command(":q")
		end,
	})
end
