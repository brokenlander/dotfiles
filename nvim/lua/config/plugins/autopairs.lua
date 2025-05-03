return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
  config = function()
    local npairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")
    
    npairs.setup({
      check_ts = true, -- Use treesitter to check for pairs
      ts_config = {
        lua = {'string', 'source'},
        javascript = {'string', 'template_string'},
        python = {'string'},
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel", "vim" },
      fast_wrap = {
        map = '<C-e>', -- Ctrl+e to wrap with pairs
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%)%>%]%)%}%,]]=],
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'Search',
        highlight_grey = 'Comment',
      },
      -- Autopairs behavior
      enable_moveright = true,
      enable_afterquote = true,
      enable_check_bracket_line = true,
      enable_bracket_in_quote = true, 
      break_undo = true, -- make autopairs and a new line separate undo events
      map_cr = true, -- map <CR> to pair completion
      map_bs = true, -- map <BS> to delete pairs
      map_c_h = false, -- map <C-h> to delete a pair
      map_c_w = false, -- map <C-w> to delete a pair if possible
    })
    
    -- Add spaces between parentheses
    -- Before: (|)
    -- Insert: <space>
    -- After: ( | )
    npairs.add_rules({
      Rule(' ', ' ')
        :with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ '()', '[]', '{}' }, pair)
        end),
      Rule('( ', ' )')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%)') ~= nil
        end)
        :use_key(')'),
      Rule('{ ', ' }')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%}') ~= nil
        end)
        :use_key('}'),
      Rule('[ ', ' ]')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%]') ~= nil
        end)
        :use_key(']'),
    })
    
    -- Add rules for specific filetypes
    -- Triple backticks for markdown code blocks
    npairs.add_rules({
      Rule("```", "```", {"markdown", "vimwiki"})
        :with_cr(function(opts)
          local close = opts.char
          local indent = string.rep(' ', vim.fn.indent(opts.line))
          return '\n' .. indent .. '\n' .. indent .. close
        end)
    })
    
    -- Integration with nvim-cmp
    -- If you want insert `(` after select function or method item
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )
  end
}
