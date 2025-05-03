return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" },
  },
  config = function()
    -- Window layout
    vim.g.undotree_WindowLayout = 2  -- Window layout: 1-4, see help for details

    -- Window size
    vim.g.undotree_SplitWidth = 30   -- Undotree window width
    vim.g.undotree_DiffpanelHeight = 10  -- Diff panel height

    -- Undotree window position
    vim.g.undotree_SetFocusWhenToggle = 1  -- Focus undotree when opening

    -- Appearance settings
    vim.g.undotree_TreeNodeShape = '●'      -- The node shape
    vim.g.undotree_TreeVertShape = '│'      -- The vertical branch shape
    vim.g.undotree_TreeSplitShape = '╱'     -- The split shape
    vim.g.undotree_TreeReturnShape = '╲'    -- The return shape
    vim.g.undotree_DiffCommand = "diff"     -- The diff command to use
    vim.g.undotree_RelativeTimestamp = 1    -- Use relative timestamps
    vim.g.undotree_ShortIndicators = 0      -- Use short indicators
    vim.g.undotree_HighlightChangedText = 1 -- Highlight changed text
    vim.g.undotree_HighlightChangedWithSign = 1 -- Show sign column for changes
    vim.g.undotree_HelpLine = 1             -- Show help line
    vim.g.undotree_CursorLine = 1           -- Show cursor line

    -- Set up persistent undo
    if vim.fn.has("persistent_undo") == 1 then
      local target_path = vim.fn.expand('~/.undodir')
      
      -- Create the directory if it doesn't exist
      if vim.fn.isdirectory(target_path) == 0 then
        vim.fn.mkdir(target_path, "p", 0700)
      end
      
      vim.opt.undodir = target_path
      vim.opt.undofile = true
    end

    -- Create an autocommand to close undotree when it's the last window
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        -- Check if undotree is open and the last window
        local wins = vim.api.nvim_list_wins()
        if #wins == 1 then
          local buf = vim.api.nvim_win_get_buf(wins[1])
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if string.match(buf_name, "undotree_") then
            vim.cmd("quit")
          end
        end
      end,
      nested = true,
    })
    
    -- Add to the which-key cheat sheet
    local which_key_ok, which_key = pcall(require, "which-key")
    if which_key_ok then
      -- Configuration already handled by the keys entry in the plugin spec
    end
  end
}
