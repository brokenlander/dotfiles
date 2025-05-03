return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 
    'nvim-tree/nvim-web-devicons',
    'lewis6991/gitsigns.nvim'  -- Add gitsigns as a dependency
  },
  event = "VeryLazy",
  config = function()
    -- Git branch name and status with better symbols
    local function git_branch()
      local head = vim.b.gitsigns_head or vim.g.gitsigns_head
      if head then
        return ' ' .. head
      end
      return ''
    end

    -- LSP server name and status
    local function lsp_status()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        return ''
      end
      
      local client_names = {}
      for _, client in ipairs(clients) do
        if client.name ~= "null-ls" and client.name ~= "copilot" then
          table.insert(client_names, client.name)
        end
      end
      
      return ' ' .. table.concat(client_names, ", ")
    end

    -- Custom theme with distinct colors for modes
    local custom_theme = require('lualine.themes.auto')
    
    -- Save the original normal mode color
    local normal_bg = custom_theme.normal.a.bg
    
    -- Override command mode color to be distinct from normal
    custom_theme.command = {
      a = { bg = '#569CD6', fg = '#000000', gui = 'bold' }, -- Command (blue)
      b = custom_theme.normal.b,
      c = custom_theme.normal.c,
    }
    
    -- Normal mode stays with original theme color (typically purple/magenta in most themes)
    -- We don't modify custom_theme.normal
    
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = custom_theme,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = { 'alpha', 'dashboard', 'NvimTree', 'Outline' },
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true, -- Use global statusline
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {
          'mode' -- Show full mode name
        },
        lualine_b = {
          { git_branch },
          { 
            'diff', 
            colored = true,
            diff_color = {
              added = 'DiffAdd',
              modified = 'DiffChange',
              removed = 'DiffDelete',
            },
            symbols = { added = ' ', modified = ' ', removed = ' ' },
          },
          { 
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            sections = { 'error', 'warn', 'info', 'hint' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            colored = true,
            update_in_insert = false,
            always_visible = false,
          }
        },
        lualine_c = {
          {
            'filename',
            path = 1, -- Relative path
            symbols = {
              modified = '●',
              readonly = '',
              unnamed = '[No Name]',
              newfile = '[New]',
            }
          }
        },
        lualine_x = {
          lsp_status,
          'encoding',
          { 'fileformat', symbols = { unix = ' ', dos = ' ', mac = ' ' } },
          'filetype'
        },
        lualine_y = {
          { 'progress', padding = { left = 1, right = 0 } }
        },
        lualine_z = {
          { 'location', padding = { left = 1, right = 1 } }
        }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 
          {
            'filename',
            path = 1, -- Relative path
            symbols = {
              modified = '●',
              readonly = '',
              unnamed = '[No Name]',
            }
          }
        },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { 'nvim-tree', 'fugitive', 'toggleterm', 'quickfix' }
    }
  end
}
