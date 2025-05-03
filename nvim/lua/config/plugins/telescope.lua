return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8", -- Use the stable version
    dependencies = { 
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",
      "folke/todo-comments.nvim",
    },
    config = function()
      -- Import required modules
      local actions = require("telescope.actions")
      local telescope = require("telescope")
      
      -- Basic telescope configuration
      telescope.setup({
        defaults = {
          -- Default configuration
          path_display = {"smart"},
          mappings = {
            i = {
              ["<C-h>"] = "which_key",
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist
            }
          }
        },
        pickers = {
          -- Configure specific pickers
          find_files = {
            theme = "dropdown",
          }
        }
      })
      
      -- Load the fzf extension
      telescope.load_extension("fzf")
      
      -- Set up keymaps
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'Telescope find recent files' })
      vim.keymap.set('n', '<leader>\\', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Telescope git files' })
      vim.keymap.set('n', '<leader>fc', builtin.grep_string, { desc = 'Find string under cursor in cwd' })
      vim.keymap.set('n', '<leader>ft', '<cmd>TodoTelescope<cr>', { desc = 'Find todos' })
    end
  }
}
