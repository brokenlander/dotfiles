return {
	-- Theme collection
	{
		"rockyzhang24/arctic.nvim",
		branch = "v2",
		lazy = true,
		priority = 1000,
		dependencies = { "rktjmp/lush.nvim" },
	},
	{
		"loctvl842/monokai-pro.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		priority = 1000,
	},

	-- Theme Manager attached to an existing plugin
	{
		"nvim-lua/plenary.nvim", -- This is commonly installed already
		lazy = false,
		priority = 1001,
		config = function()
			-- List of themes
			local themes = {
				{
					name = "arctic",
					setup = function()
						vim.cmd("colorscheme arctic")
					end,
				},
				{
					name = "monokai-pro",
					setup = function()
						require("monokai-pro").setup({
							filter = "ristretto",
							transparent_background = false,
							terminal_colors = true,
							devicons = true,
							styles = {
								comment = { italic = true },
								keyword = { italic = true },
								type = { italic = true },
								parameter = { italic = true },
								storageclass = { italic = true },
								structure = { italic = true },
								annotation = { italic = true },
								tag_attribute = { italic = true },
							},
							inc_search = "background",
							background_clear = {
								"toggleterm",
								"telescope",
								"renamer",
								"notify",
							},
							plugins = {
								bufferline = {
									underline_selected = false,
									underline_visible = false,
								},
								indent_blankline = {
									context_highlight = "pro",
									context_start_underline = false,
								},
							},
						})
						vim.cmd("colorscheme monokai-pro")
					end,
				},
				{
					name = "catppuccin",
					setup = function()
						require("catppuccin").setup({
							flavour = "mocha",
							background = {
								dark = "mocha",
								light = "latte",
							},
							transparent_background = false,
							term_colors = true,
							color_overrides = {
								mocha = {
									base = "#14111c",  -- Darker with more purple tint
									mantle = "#100d18",  -- Slightly darker with purple
									crust = "#0c0a13",  -- Darkest with purple
								},
							},
							styles = {
								comments = { "italic" },
								conditionals = { "italic" },
								loops = {},
								functions = {},
								keywords = {},
								strings = {},
								variables = {},
								numbers = {},
								booleans = {},
								properties = {},
								types = {},
							},
							integrations = {
								cmp = true,
								gitsigns = true,
								nvimtree = true,
								treesitter = true,
								notify = false,
							},
						})
						vim.cmd("colorscheme catppuccin")
					end,
				},
				{
					name = "default-enhanced",
					setup = function()
						-- Reset to default first
						vim.cmd("colorscheme default")

						-- Then enhance with better syntax highlighting
						local highlights = {
							-- Basic syntax matching Catppuccin styling
							Boolean = { fg = "#569CD6" }, -- No italic
							Number = { fg = "#B5CEA8" },
							String = { fg = "#CE9178" },
							Identifier = { fg = "#9CDCFE" },
							Function = { fg = "#DCDCAA" },
							Statement = { fg = "#C586C0" }, -- No italic
							Keyword = { fg = "#569CD6" }, -- No italic
							Conditional = { fg = "#C586C0", italic = true }, -- Keep italic for conditionals like Catppuccin
							Operator = { fg = "#D4D4D4" },
							Type = { fg = "#4EC9B0" }, -- No italic
							Comment = { fg = "#6A9955", italic = true }, -- Keep italic for comments like Catppuccin

							-- UI elements
							LineNr = { fg = "#858585" },
							CursorLine = { bg = "#2C2C2C" },
							CursorLineNr = { fg = "#DCDCAA", bold = true },
							Visual = { bg = "#264F78" },
							Search = { bg = "#613214", fg = "#FFFFFF" },
							IncSearch = { bg = "#613214", fg = "#FFFFFF" },

							-- Special
							Todo = { fg = "#FF8C00", bold = true, italic = true },
							Error = { fg = "#F44747" },
							WarningMsg = { fg = "#FF8C00" },
						}

						-- Apply the highlights
						for group, settings in pairs(highlights) do
							vim.api.nvim_set_hl(0, group, settings)
						end
					end,
				},
			}

			-- Global variable to track current theme index
			vim.g.current_theme_index = 0

			-- Function to cycle through themes
			_G.cycle_theme = function()
				-- Get next theme index
				local next_index = (vim.g.current_theme_index % #themes) + 1
				vim.g.current_theme_index = next_index

				-- Apply the theme
				local theme = themes[next_index]
				theme.setup()

				-- Notify user
				vim.notify("Switched to theme: " .. theme.name, vim.log.levels.INFO)
			end

			-- Function to switch to a specific theme by name
			_G.set_theme = function(theme_name)
				for i, theme in ipairs(themes) do
					if theme.name == theme_name then
						vim.g.current_theme_index = i
						theme.setup()
						vim.notify("Switched to theme: " .. theme.name, vim.log.levels.INFO)
						return
					end
				end
				vim.notify("Theme not found: " .. theme_name, vim.log.levels.ERROR)
			end

			-- Create commands to switch themes
			vim.api.nvim_create_user_command("ThemeCycle", function()
				_G.cycle_theme()
			end, {})
			vim.api.nvim_create_user_command("ThemeSet", function(opts)
				_G.set_theme(opts.args)
			end, {
				nargs = 1,
				complete = function()
					local names = {}
					for _, theme in ipairs(themes) do
						table.insert(names, theme.name)
					end
					return names
				end,
			})

			-- Set up keybinding for quick cycling
			vim.keymap.set("n", "<leader>tt", _G.cycle_theme, { desc = "Cycle through themes" })

			-- Initialize with catppuccin theme
			_G.set_theme("catppuccin")
		end,
	},
}
