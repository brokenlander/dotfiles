return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    -- Sources
    "hrsh7th/cmp-buffer",     -- Buffer completions
    "hrsh7th/cmp-path",       -- Path completions
    "hrsh7th/cmp-cmdline",    -- Command line completions
    "hrsh7th/cmp-nvim-lsp",   -- LSP completions
    "hrsh7th/cmp-nvim-lua",   -- Lua completions for Neovim API
    "saadparwaiz1/cmp_luasnip", -- Snippet completions
    
    -- Snippets
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        "rafamadriz/friendly-snippets", -- Preconfigured snippets
      },
    },
    
    -- Optional but recommended
    "onsails/lspkind.nvim",   -- Adds pictograms to completions
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    
    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Super-Tab like mapping
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered({
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
          border = "rounded",
          scrollbar = false,
        }),
        documentation = cmp.config.window.bordered({
          winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder",
          border = "rounded",
          scrollbar = false,
        }),
      },
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          ellipsis_char = "...",
          menu = {
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            nvim_lua = "[Lua]",
            path = "[Path]",
          },
        }),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        
        -- Tab completion with SuperTab-like behavior
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "nvim_lua", priority = 500 },
        { name = "buffer", priority = 250 },
        { name = "path", priority = 200 },
      }),
      -- Enable completion preselect
      preselect = cmp.PreselectMode.Item,
      -- Disable ghost text for now (Neovim 0.10+ has native completion hint support)
      experimental = {
        ghost_text = false,
      },
    })
    
    -- Use buffer source for `/` and `?` (search)
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" }
      }
    })
    
    -- Use cmdline & path source for ':' (command line)
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
        { name = "cmdline" }
      }),
      matching = { disallow_symbol_nonprefix_matching = false }
    })
  end
}
