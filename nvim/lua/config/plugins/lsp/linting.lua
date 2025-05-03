return {
	"mfussenegger/nvim-lint",
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
		}
		-- Create state for toggling diagnostics visibility
		local diagnostics_active = false -- Changed to false to have diagnostics off by default

		-- Function to toggle diagnostics display
		local function toggle_diagnostics()
			diagnostics_active = not diagnostics_active
			if diagnostics_active then
				-- Turn on inline diagnostics
				vim.diagnostic.config({
					virtual_text = true,
					signs = true,
					underline = true,
					update_in_insert = false,
					severity_sort = true,
				})
				-- Run linting
				lint.try_lint()
				vim.notify("Linting enabled", vim.log.levels.INFO)
			else
				-- Turn off inline diagnostics
				vim.diagnostic.config({
					virtual_text = false,
					signs = false,
					underline = false,
					update_in_insert = false,
					severity_sort = true,
				})
				vim.notify("Linting disabled", vim.log.levels.INFO)
			end
		end

		-- Initialize diagnostics to off on startup
		vim.diagnostic.config({
			virtual_text = false,
			signs = false,
			underline = false,
			update_in_insert = false,
			severity_sort = true,
		})

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				if diagnostics_active then
					lint.try_lint()
				end
			end,
		})
		-- Set up keybinding to toggle diagnostics
		vim.keymap.set("n", "<leader>l", toggle_diagnostics, { desc = "Toggle linting" })
	end,
}
