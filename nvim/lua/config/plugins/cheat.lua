return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"echasnovski/mini.icons",
		},
		opts = {
			preset = "helix",
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader><tab>", group = "tabs" },
					{ "<leader>c", group = "code" },
					{ "<leader>d", group = "debug" },
					{ "<leader>e", group = "files" },
					{ "<leader>dp", group = "profiler" },
					{ "<leader>f", group = "telescope" },
					{ "<leader>r", group = "buffer exit" },
					{ "<leader>v", group = "void paste", icon = { icon = "📋", color = "red" } },
					{ "<leader>g", group = "git" },
					{ "<leader>a", group = "avante" },
					{ "<leader>t", group = "tabs" },
					{ "<leader>gh", group = "git hunks" },
					{ "<leader>s", group = "session" },
					{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
					{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
					{ "<leader>h", group = "git" },
					{
						"<leader>uh",
						function()
							local cmp_cheatsheet = {
								title = "Other Shortcuts Cheat Sheet",
								width = 55,
								height = 35,
								border = "rounded",
								buf_options = {
									filetype = "markdown",
								},
							}

							local buf = vim.api.nvim_create_buf(false, true)
							vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
								"╔════════════════════════════════════════════════════╗",
								"║             Other Shortcuts Cheat Sheet            ║",
								"╚════════════════════════════════════════════════════╝",
								"",
								"Insert Mode:",
								"┌──────────────┬────────────────────────────────────┐",
								"│ Shortcut     │ Action                             │",
								"├──────────────┼────────────────────────────────────┤",
								"│ Ctrl-Space   │ Open completion menu               │",
								"│ Ctrl-e       │ Cancel completion                  │",
								"│ Tab          │ Next item / Expand snippet         │",
								"│ Shift-Tab    │ Previous item                      │",
								"│ Ctrl-b / f   │ Scroll documentation               │",
								"│ Enter        │ Confirm selection                  │",
								"│ Ctrl-e       │ Fast wrap                          │",
								"└──────────────┴────────────────────────────────────┘",
								"",
								"Normal Mode:",
								"┌──────────────┬────────────────────────────────────┐",
								"│ Shortcut     │ Action                             │",
								"├──────────────┼────────────────────────────────────┤",
								"│ Tab          │ Cycle to next buffer               │",
								"│ Shift-Tab    │ Cycle to previous buffer           │",
								"│ Ctrl-a       │ Select and copy all                │",
								"└──────────────┴────────────────────────────────────┘",
								"",
								"Visual Mode:",
								"┌──────────────┬────────────────────────────────────┐",
								"│ Shortcut     │ Action                             │",
								"├──────────────┼────────────────────────────────────┤",
								"│ Ctrl-a       │ Select and copy all                │",
								"└──────────────┴────────────────────────────────────┘",
								"",
								"→ Press any key to close this window ←",
							})

							-- Use nvim-web-devicons if available
							local width = cmp_cheatsheet.width
							local height = cmp_cheatsheet.height
							local row = math.floor((vim.o.lines - height) / 2)
							local col = math.floor((vim.o.columns - width) / 2)

							local win_opts = {
								relative = "editor",
								width = width,
								height = height,
								row = row,
								col = col,
								style = "minimal",
								border = cmp_cheatsheet.border,
							}

							local win = vim.api.nvim_open_win(buf, true, win_opts)
							vim.api.nvim_win_set_option(win, "winblend", 0)

							-- Set buffer options
							if cmp_cheatsheet.buf_options then
								for k, v in pairs(cmp_cheatsheet.buf_options) do
									vim.api.nvim_buf_set_option(buf, k, v)
								end
							end

							-- Close on any key
							vim.api.nvim_buf_set_keymap(
								buf,
								"n",
								"<leader>",
								"<Cmd>close<CR>",
								{ noremap = true, silent = true }
							)
							vim.api.nvim_buf_set_keymap(
								buf,
								"n",
								"<Esc>",
								"<Cmd>close<CR>",
								{ noremap = true, silent = true }
							)
							vim.api.nvim_buf_set_keymap(
								buf,
								"n",
								"q",
								"<Cmd>close<CR>",
								{ noremap = true, silent = true }
							)
							vim.api.nvim_buf_set_keymap(
								buf,
								"n",
								"<CR>",
								"<Cmd>close<CR>",
								{ noremap = true, silent = true }
							)

							vim.api.nvim_create_autocmd("BufLeave", {
								buffer = buf,
								once = true,
								callback = function()
									vim.schedule(function()
										if vim.api.nvim_win_is_valid(win) then
											vim.api.nvim_win_close(win, true)
										end
										if vim.api.nvim_buf_is_valid(buf) then
											vim.api.nvim_buf_delete(buf, { force = true })
										end
									end)
								end,
							})
						end,
						desc = "Completion Cheat Sheet",
					},
					-- Add Ctrl-a keybinding for Normal and Visual mode
					{ "<C-a>", "ggVGy", desc = "Select and copy all" },
					{ "[", group = "prev" },
					{ "]", group = "next" },
					{ "g", group = "goto" },
					{ "gs", group = "surround" },
					{ "z", group = "fold" },
					{
						"<leader>b",
						group = "buffer",
						expand = function()
							return require("which-key.extras").expand.buf()
						end,
					},
					{
						"<leader>w",
						group = "windows",
						proxy = "<c-w>",
						expand = function()
							return require("which-key.extras").expand.win()
						end,
					},
					-- Window navigation with arrow keys
					{ "<leader>w<Up>", "<C-w>k", desc = "Move to window above" },
					{ "<leader>w<Down>", "<C-w>j", desc = "Move to window below" },
					{ "<leader>w<Left>", "<C-w>h", desc = "Move to window left" },
					{ "<leader>w<Right>", "<C-w>l", desc = "Move to window right" },
					-- better descriptions
					{ "gx", desc = "Open with system app" },
				},
			},
			triggers = {
				{ "<auto>", mode = "nixsotc" },
				{ "<leader>" },
			},
			win = {
				border = "rounded",
				padding = { 2, 2, 2, 2 },
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Keymaps (which-key)",
			},
			{
				"<c-w><space>",
				function()
					require("which-key").show({ keys = "<c-w>", loop = true })
				end,
				desc = "Window Hydra Mode (which-key)",
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
		end,
	},
}
