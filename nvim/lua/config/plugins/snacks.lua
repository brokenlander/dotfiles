return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  
  ---@type snacks.Config
  opts = {
    -- Components you want to use
    input = {
      enabled = true,
      border = "rounded",
      relative = "cursor",
      min_width = 30,
      max_width = 80,
      min_height = 1,
      max_height = 20,
      win_options = {
        winblend = 0,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    },
    picker = {
      enabled = true,
      border = "rounded",
      width = 0.8,
      height = 0.6,
      win_options = {
        winblend = 0,
      },
    },
    notifier = {
      enabled = true,
      timeout = 5000,
      max_width = 100,
      max_height = 20,
      stages = "fade",
    },
    
    -- Explicitly disable components you're not using
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    image = { enabled = false },
    lazygit = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  }
}
