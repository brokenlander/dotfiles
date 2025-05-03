return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Custom header with BROKENLANDER ASCII art
		dashboard.section.header.val = {
			"",
			"██████╗ ██████╗  ██████╗ ██╗  ██╗███████╗███╗   ██╗██╗      █████╗ ███╗   ██╗██████╗ ███████╗██████╗ ",
			"██╔══██╗██╔══██╗██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║██║     ██╔══██╗████╗  ██║██╔══██╗██╔════╝██╔══██╗",
			"██████╔╝██████╔╝██║   ██║█████╔╝ █████╗  ██╔██╗ ██║██║     ███████║██╔██╗ ██║██║  ██║█████╗  ██████╔╝",
			"██╔══██╗██╔══██╗██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║██║     ██╔══██║██║╚██╗██║██║  ██║██╔══╝  ██╔══██╗",
			"██████╔╝██║  ██║╚██████╔╝██║  ██╗███████╗██║ ╚████║███████╗██║  ██║██║ ╚████║██████╔╝███████╗██║  ██║",
			"╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝",
			"",
			"                Build a man a fire and he'll be warm for a day.                ",
			"                Set a man on fire and he'll be warm for the rest of his life.                ",
			"",
		}

		-- Enhanced buttons with icons and better organization
		dashboard.section.buttons.val = {
			-- File operations
			dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
			dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
			dashboard.button("g", "  Find word", ":Telescope live_grep<CR>"),

			-- Spacing
			{ type = "padding", val = 1 },

			-- Project management
			dashboard.button("p", "  Projects", ":Telescope projects<CR>"),
			dashboard.button("s", "  Sessions", ":Telescope session-lens search_session<CR>"),

			-- Spacing
			{ type = "padding", val = 1 },

			-- Git operations
			dashboard.button("gs", "  Git status", ":Telescope git_status<CR>"),
			dashboard.button("gc", "  Git commits", ":Telescope git_commits<CR>"),
			dashboard.button("gb", "  Git branches", ":Telescope git_branches<CR>"),

			-- Spacing
			{ type = "padding", val = 1 },

			-- Utility tools
			dashboard.button("t", "  Todo list", ":TodoTelescope<CR>"),
			dashboard.button(
				"c",
				"  Cheat sheet",
				":lua require('which-key').show({ mode = 'n', prefix = '<leader>hk' })<CR>"
			),
			dashboard.button("m", "  Mason", ":Mason<CR>"),

			-- Spacing
			{ type = "padding", val = 1 },

			-- Configuration
			dashboard.button("h", "  Healthcheck", ":checkhealth<CR>"),
			dashboard.button("u", "  Update plugins", ":Lazy update<CR>"),
			dashboard.button("q", "  Quit", ":qa<CR>"),
		}

		-- Function to get git branch
		local function get_git_branch()
			local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
			if branch ~= "" then
				return " " .. branch
			else
				return ""
			end
		end

		-- Function to count TODOs in project
		local function count_todos()
			local count = vim.fn.system(
				"rg -i 'TODO|FIXME|HACK|NOTE' --no-filename --no-heading --no-line-number 2>/dev/null | wc -l | tr -d '\n'"
			)
			count = tonumber(count) or 0
			if count > 0 then
				return "󰔱 " .. count .. " TODOs"
			else
				return ""
			end
		end

		-- System stats and plugin count
		local function get_stats()
			local stats = "Neovim v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch

			-- Add plugin count if lazy.nvim is available
			local ok, lazy = pcall(require, "lazy")
			if ok then
				stats = stats .. "  •  " .. #vim.tbl_keys(lazy.plugins()) .. " plugins"
			end

			-- Add git branch info
			local branch = get_git_branch()
			if branch ~= "" then
				stats = stats .. "  •  " .. branch
			end

			-- Add todo count if ripgrep is available
			if vim.fn.executable("rg") == 1 then
				local todos = count_todos()
				if todos ~= "" then
					stats = stats .. "  •  " .. todos
				end
			end

			return stats
		end

		-- Add system stats to the footer
		dashboard.section.footer.val = get_stats()

		-- Add a fortune quote below the stats
		local fortune_section = dashboard.section.footer

		-- Create a separate section for fortune
		dashboard.section.fortune = {
			type = "text",
			val = require("alpha.fortune")(),
			opts = {
				position = "center",
				hl = "AlphaFooter",
			},
		}

		-- Styling
		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.buttons.opts.hl = "AlphaButtons"
		dashboard.section.footer.opts.hl = "AlphaFooter"

		-- Set padding between sections
		dashboard.config.layout = {
			{ type = "padding", val = 2 },
			dashboard.section.header,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 2 },
			dashboard.section.footer,
			{ type = "padding", val = 1 },
			dashboard.section.fortune,
		}

		-- Setup dashboard options
		dashboard.opts.opts.noautocmd = true

		-- Initialize alpha
		alpha.setup(dashboard.opts)

		-- Custom highlights - orange header to match shortcuts
		vim.cmd([[
            highlight AlphaHeader guifg=#FC9867      " Orange for BROKENLANDER text (same as shortcuts)
            highlight AlphaButtons guifg=#78DCE8      " Light blue for buttons
            highlight AlphaFooter guifg=#a89984      " Original muted brown for footer quotes
            autocmd FileType alpha setlocal nofoldenable
        ]])

		-- Automatically open alpha when no arguments are provided
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
					require("alpha").start()
				end
			end,
		})
	end,
}
