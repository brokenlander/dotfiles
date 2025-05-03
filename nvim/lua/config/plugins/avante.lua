return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	version = false, -- Use latest version
	opts = {
		provider = "claude", -- Setting provider to Claude

		-- Claude configuration
		claude = {
			endpoint = "https://api.anthropic.com",
			model = "claude-3-7-sonnet-latest", -- Latest Claude 3.7 Sonnet model
			timeout = 60000, -- 60 seconds
			temperature = 0, -- More deterministic responsesavant
			max_tokens = 8192,
		},

		-- Visual appearance
		view = {
			side = "right", -- Show sidebar on right
			width = 60, -- Width of sidebar
			show_diff_preview = true, -- Show diff preview
			code_block_highlight = true, -- Highlight code blocks
		},
		-- Disable key hints
		hints = {
			enabled = false,
		},
		-- Behavior settings
		behaviour = {
			auto_diff = true, -- Auto-generate diffs
			enable_cursor_planning_mode = true, -- Better with various models
			enable_claude_text_editor_tool_mode = true, -- For Claude 3.5+
		},

		-- Web search settings (if needed)
		web_search_engine = {
			provider = "tavily", -- Alternative: "serpapi", "searchapi", "google", "kagi", "brave", or "searxng"
			proxy = nil, -- Set proxy if needed, e.g., "http://127.0.0.1:7890"
		},

		-- RAG service (optional - disabled by default)
		rag_service = {
			enabled = false, -- Set to true to enable
			host_mount = os.getenv("HOME"), -- Host mount path
			provider = "openai", -- Provider for RAG service
			llm_model = "", -- LLM model (defaults based on provider)
			embed_model = "", -- Embedding model (defaults based on provider)
			endpoint = "https://api.openai.com/v1", -- API endpoint
		},

		-- File selector settings
		file_selector = {
			provider = "telescope", -- Options: "native", "telescope", "fzf_lua", "mini_pick"
		},

		-- Disable specific tools if needed
		-- disabled_tools = { "python" }, -- Uncomment to disable specific tools

		-- Custom highlighting
		highlights = {
			diff = {
				current = "DiffAdd",
				incoming = "DiffChange",
			},
		},
	},
	-- Required dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-telescope/telescope.nvim", -- For file selection
		"hrsh7th/nvim-cmp", -- For command autocompletion
		"nvim-tree/nvim-web-devicons", -- For icons
		{
			-- Support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = { insert_mode = true },
					use_absolute_path = true, -- Required for Windows
				},
			},
		},
		{
			-- Markdown rendering
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
	-- Build command
	build = "make", -- For Windows: "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"

	-- Configure key mappings
	keys = {
		{ "<leader>aa", "<cmd>AvanteToggle<CR>", desc = "Toggle Avante sidebar" },
		{ "<leader>at", "<cmd>AvanteToggle<CR>", desc = "Toggle Avante sidebar" },
		{ "<leader>ar", "<cmd>AvanteRefresh<CR>", desc = "Refresh Avante" },
		{ "<leader>af", "<cmd>AvanteFocus<CR>", desc = "Switch Avante focus" },
		{ "<leader>a?", "<cmd>AvanteModels<CR>", desc = "Select model" },
		{ "<leader>ae", "<cmd>AvanteEdit<CR>", desc = "Edit selected blocks" },
		{ "<leader>aS", "<cmd>AvanteStop<CR>", desc = "Stop AI request" },
		{ "<leader>ah", "<cmd>AvanteHistory<CR>", desc = "Select chat history" },
		{ "<leader>aw", "<cmd>AvanteClear<CR>", desc = "Wipe chat history" },
	},

	-- Plugin configuration
	config = function(_, opts)
		require("avante").setup(opts)

		-- Setup additional commands
		vim.api.nvim_create_user_command("AvanteAsk", function(args)
			require("avante").ask(args.args)
		end, { nargs = "*", desc = "Ask Avante about your code" })

		-- Set global statusline for better support
		vim.opt.laststatus = 3
	end,
}
