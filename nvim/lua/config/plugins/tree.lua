return {
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- optional, for file icons
		},
		cmd = {
			"NvimTreeToggle",
			"NvimTreeFocus",
			"NvimTreeFindFile",
			"NvimTreeCollapse",
		},
		keys = {
			{ "<leader>ee", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
			{ "<leader>er", "<cmd>NvimTreeFocus<CR>", desc = "Focus NvimTree" },
			{ "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", desc = "Toggle NvimTree" },
		},
		config = function()
			-- Disable netrw
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			-- Enable 24-bit color
			vim.opt.termguicolors = true

			require("nvim-tree").setup({
				sort = {
					sorter = "case_sensitive",
				},
				view = {
					width = 30,
					adaptive_size = true,
				},
				renderer = {
					group_empty = true,
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
					},
				},
				filters = {
					dotfiles = false, -- Show hidden files
				},
				git = {
					enable = true,
					ignore = false, -- Don't hide files from .gitignore
				},
				actions = {
					open_file = {
						quit_on_open = false, -- Don't close when opening a file
						resize_window = true, -- Resize the tree when opening a file
						window_picker = {
							enable = false, -- Disable window picker
						},
					},
				},
				on_attach = function(bufnr)
					local api = require("nvim-tree.api")

					-- Helper function to create keymap options
					local function opts(desc)
						return {
							desc = "nvim-tree: " .. desc,
							buffer = bufnr,
							noremap = true,
							silent = true,
							nowait = true,
						}
					end

					-- Apply default mappings
					api.config.mappings.default_on_attach(bufnr)

					-- Custom mappings
					vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
					vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
					vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
					vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
				end,
			})

			-- Custom highlights
			vim.cmd([[
        highlight NvimTreeSpecialFile guifg=#ff80ff gui=underline
        highlight NvimTreeSymlink guifg=Yellow gui=italic
      ]])
		end,
	},
}
