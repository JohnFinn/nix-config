-- hjkl
vim.api.nvim_command([[
	noremap ; l
	noremap l k
	noremap k j
	noremap j h
	noremap h ;

	noremap gk gj
	noremap gl gk

	set tabstop=2 shiftwidth=2
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

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set({ "n", "x" }, "<leader>w", "<cmd>set wrap!<cr>")

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
	end,
})

vim.filetype.add({
	extension = { tfvars = "terraform" },
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
	dev = {
		---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
		-- TODO: figure out proper way of doing it like here https://nixalted.com/
		path = tostring(Path(vim.api.nvim_list_runtime_paths()[3]):parent()),
		---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
		patterns = {}, -- For example {"folke"}
		fallback = false, -- Fallback to git when local plugin doesn't exist
	},
	install = {
		-- Safeguard in case we forget to install a plugin with Nix
		missing = false,
	},
	performance = {
		reset_packpath = true,
		rtp = {
			reset = true,
		},
	},
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
			end,
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

				require("mini.surround").setup({})
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
					format_on_save = true,
					formatters_by_ft = {
						nix = { "alejandra" },
						lua = { "stylua" },
						cpp = { "clang_format" },
						tex = { "latexindent" },
						rust = { "rustfmt" },
						python = { "black" },
						markdown = { "mdformat" },
						-- -- Conform will run multiple formatters sequentially
						-- python = { "isort", "black" },
						-- Use a sub-list to run only the first available formatter
						javascript = { { "prettierd", "prettier" } },
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
			event = "VeryLazy",
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
				require("lspconfig").clangd.setup({})
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
			end,
			-- stylua: ignore
			keys = {
				{ "<leader>db", mode = { "n", "x" }, function() require('dap').toggle_breakpoint() end, desc = "Toggle breakpoint" },
				{ "<leader>dc", mode = { "n", "x" }, function() require('dap').continue() end, desc = "Debug continue" },
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
			dependencies = {
				"nvim-treesitter/nvim-treesitter-textobjects",
				dev = true,
			},
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
			dependencies = {
				{
					"folke/twilight.nvim",
					dev = true,
				},
			},
			opts = {
				plugins = {
					wezterm = {
						enabled = true,
						font = "+2",
					},
				},
			},
		},
	},
})
