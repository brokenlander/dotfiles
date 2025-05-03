return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        require('bufferline').setup({
            options = {
                mode = "tabs",
                separator_style = "slant",
                diagnostics = "nvim_lsp",
                numbers = "ordinal",
                show_buffer_close_icons = false,
                show_close_icon = false
            }
        })

        -- Basic buffer navigation keymaps
        --vim.keymap.set('n', '<TAB>', ':BufferLineCycleNext<CR>', { silent = true })
        --vim.keymap.set('n', '<S-TAB>', ':BufferLineCyclePrev<CR>', { silent = true })
    end
}
