return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- A list of parser names, or "all"
        ensure_installed = {
          -- Your requested languages
          "python",
          "javascript",
          "typescript",
          "lua",
          
          -- Additional languages useful for Node.js development
          "tsx",           -- TypeScript JSX
          "json",          -- JSON files
          "html",          -- HTML
          "css",           -- CSS
          "yaml",          -- YAML for configs
          "markdown",      -- Markdown documentation
          "markdown_inline", -- Inline markdown
          "bash",          -- Shell scripts
          "regex",         -- Regular expressions
          "dockerfile",    -- Dockerfiles
          "graphql",       -- GraphQL
          "prisma",        -- Prisma Schema
          
          -- Configuration languages
          "toml",          -- TOML
          "vim",           -- Vim script
          "vimdoc",        -- Vim help docs
          "query",         -- Treesitter query language
        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        -- List of parsers to ignore installing (or "all")
        ignore_install = {},

        highlight = {
          -- Enable the module
          enable = true,

          -- Using treesitter for these filetypes is recommended
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true,
        },

        -- Text objects - select based on language syntax
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ai"] = "@conditional.outer",
              ["ii"] = "@conditional.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["as"] = "@statement.outer",
              ["is"] = "@statement.inner",
            },
          },
          
          -- Move between text objects
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]i"] = "@conditional.outer",
              ["]l"] = "@loop.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
              ["]I"] = "@conditional.outer",
              ["]L"] = "@loop.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[i"] = "@conditional.outer",
              ["[l"] = "@loop.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
              ["[I"] = "@conditional.outer",
              ["[L"] = "@loop.outer",
            },
          },
        },
      })
    end,
  }
}
