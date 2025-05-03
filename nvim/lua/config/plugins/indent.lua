return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "HiPhish/rainbow-delimiters.nvim",
  },
  keys = {
    -- Toggle both indent lines and the list option together for better consistency
    { "<leader>ui", "<cmd>IBLToggle<cr>:set list!<cr>", desc = "Toggle Indent Lines" },
  },
  config = function()
    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }
    local hooks = require("ibl.hooks")
    -- Create the highlight groups in the highlight setup hook
    -- This ensures they are reset every time the colorscheme changes
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    end)
    -- Set up rainbow delimiters
    vim.g.rainbow_delimiters = { highlight = highlight }
    
    -- Configure indent-blankline
    require("ibl").setup({
      indent = {
        char = "│", -- Use a simple vertical line for indentation
      },
      scope = {
        enabled = true,
        highlight = highlight,
        show_start = true,
        show_end = true,
        injected_languages = true,
        priority = 500,
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
      -- Set enabled to false to disable at startup
      enabled = false
    })
    
    -- Also ensure 'list' is off at startup for consistency with indent lines being off
    vim.opt.list = false
    
    -- Register the scope highlighting from extmarks
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
  end,
}
