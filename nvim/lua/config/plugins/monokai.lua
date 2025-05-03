return {
	"loctvl842/monokai-pro.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("monokai-pro").setup({
			filter = "ristretto",
			transparent_background = false,
			terminal_colors = true,
			devicons = true,

			-- Complete style options
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

			-- Search highlighting style
			inc_search = "background", -- options: "background" or "underline"

			-- Background clearing for specific plugins
			background_clear = {
				"toggleterm",
				"telescope",
				"renamer",
				"notify",
			},

			-- Plugin-specific configurations
			plugins = {
				bufferline = {
					underline_selected = false,
					underline_visible = false,
				},
				indent_blankline = {
					context_highlight = "default", -- options: "default" or "pro"
					context_start_underline = false,
				},
			},
		})
		vim.cmd([[colorscheme monokai-pro]])
	end,
}
