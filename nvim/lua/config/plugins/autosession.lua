return {
  'rmagatti/auto-session',
  lazy = false,
  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    auto_restore_last_session = false,
    auto_save = false,
    auto_restore = false,
    -- log_level = 'debug',
  },
  config = function(_, opts)
    require("auto-session").setup(opts)
    
    -- Add keymappings for save and restore session
    vim.keymap.set("n", "<leader>ss", function() 
      require("auto-session").SaveSession() 
    end, { desc = "Save session" })
    
    vim.keymap.set("n", "<leader>sr", function() 
      require("auto-session").RestoreSession() 
    end, { desc = "Restore session" })
    
    -- Add keymapping for session list/search
    vim.keymap.set("n", "<leader>sl", function()
      vim.cmd("SessionSearch")
    end, { desc = "List/search sessions" })
    
    -- Add keymapping for session delete
    vim.keymap.set("n", "<leader>sd", function()
      vim.cmd("Autosession delete")
    end, { desc = "Delete session" })
  end
}
