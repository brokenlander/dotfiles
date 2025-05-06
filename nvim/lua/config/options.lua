vim.cmd("let g:netrw_liststyle =3")
local opt = vim.opt
opt.nu = true --enable line numbers
opt.relativenumber = true --relative line number
opt.tabstop = 2 --2 spaces for tab
opt.shiftwidth = 2 --2 spaces for indent
opt.expandtab = true --expand tab to spaces
opt.autoindent = true --Copy indent from current line when starting new one
opt.wrap = false --no line wrapping
opt.ignorecase = true --ignore case in search
opt.smartcase = true --unless mixed cases are usedi
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes" --show sign column so that text doesn't shift
opt.fillchars = vim.opt.fillchars + "eob: "
opt.fillchars = opt.fillchars + "eob: "
-- Use the system clipboard by default
vim.opt.clipboard = "unnamedplus"

-- Simple keymap for select all and copy
vim.api.nvim_set_keymap("n", "<C-a>", 'ggVG"+y', { noremap = true, silent = true })

--opt.clipboard:append("unnamedplus") --use system clipboard
vim.opt.clipboard = "unnamed"
opt.splitright = true
opt.splitbelow = true

-- Mouse configuration
opt.mouse = "a" -- Enable mouse in all modes
opt.mousemodel = "extend" -- Ensure right click doesn't open a menu

-- Right-click to paste mappings
vim.api.nvim_set_keymap("n", "<RightMouse>", '"+p', { noremap = true })
vim.api.nvim_set_keymap("i", "<RightMouse>", "<C-r>+", { noremap = true })
vim.api.nvim_set_keymap("v", "<RightMouse>", '"+p', { noremap = true })

-- Select text to automatically copy to clipboard without losing selection
vim.api.nvim_set_keymap(
	"v",
	"<LeftRelease>",
	":<C-u>let save_cursor = getcurpos()<CR>gv\"+y:<C-u>call setpos('.', save_cursor)<CR>gv",
	{ noremap = true, expr = false, silent = true }
)
-- Auto-copy yank operations to system clipboard as well
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		if vim.v.event.operator == "y" or vim.v.event.operator == "d" then
			vim.cmd('let @+=@"')
		end
	end,
	group = vim.api.nvim_create_augroup("AutoCopySelection", { clear = true }),
})

-- Session options for auto-session plugin
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Configure diagnostics display
vim.diagnostic.config({
	virtual_text = true, -- Show diagnostic message as virtual text
	signs = true, -- Show signs in the sign column
	underline = true, -- Underline the text with an error
	update_in_insert = false, -- Don't update diagnostics in insert mode
	severity_sort = true, -- Sort diagnostics by severity
	float = {
		source = "always", -- Show source of diagnostic in float window
		border = "rounded", -- Add border to float window
		header = "", -- Optional header
		prefix = "", -- Optional prefix
	},
})

-- Set up diagnostic signs in the gutter
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
