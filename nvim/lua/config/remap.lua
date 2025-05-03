vim.g.mapleader = " "
vim.keymap.set("n", "<leader>rd", vim.cmd.Ex, { noremap = true, desc = "Detach buffer" })
-- Add buffer delete command that preserves windows
vim.keymap.set("n", "<leader>rt", function()
	-- Save the current buffer number
	local current_buf = vim.api.nvim_get_current_buf()

	-- Switch to next buffer (wraps around if at the end)
	vim.cmd("bnext")

	-- Delete the previous buffer
	vim.cmd("bdelete " .. current_buf)
end, { noremap = true, desc = "Delete buffer but keep window" })
vim.keymap.set("n", "<leader>re", function()
	vim.cmd("bd!")
end, { noremap = true, desc = "Delete buffer" })
vim.keymap.set("n", "<leader>q", function()
	vim.cmd("qa!")
end, { noremap = true, desc = "Quit all!" })
vim.keymap.set("i", "<RightMouse>", "<C-r>+", { noremap = true, silent = true })
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { noremap = true, silent = true })

-- Tab navigation with leader + number (1-3)
vim.keymap.set("n", "<leader>1", "1gt", { desc = "Go to tab 1", noremap = true, silent = true })
vim.keymap.set("n", "<leader>2", "2gt", { desc = "Go to tab 2", noremap = true, silent = true })
vim.keymap.set("n", "<leader>3", "3gt", { desc = "Go to tab 3", noremap = true, silent = true })

-- Common tab creation and management
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab", noremap = true, silent = true })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab", noremap = true, silent = true })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { desc = "Close other tabs", noremap = true, silent = true })
-- Optional: Open current buffer in new tab
vim.keymap.set("n", "<leader>tb", ":tab split<CR>", { desc = "Open buffer in new tab", noremap = true, silent = true })

-- Disable macro recording with qq (prevent accidental macro recording)
vim.keymap.set("n", "q", function()
	-- If the next character pressed is 'q', do nothing
	local next_char = vim.fn.getcharstr()
	if next_char ~= "q" then
		-- Otherwise, record macro as usual
		vim.api.nvim_feedkeys("q" .. next_char, "n", false)
	end
	-- When qq is pressed, silently do nothing
end, { noremap = true, desc = "Record macro (qq disabled)" })

-- Add keymapping for undotree
vim.keymap.set("n", "<leader>ut", vim.cmd.UndotreeToggle, { noremap = true, desc = "Toggle Undotree" })
vim.keymap.set(
	"i",
	"<C-r>",
	'<C-r><C-o>"',
	{ noremap = true, desc = "Insert contents of named register. Inserts text literally, not as if you typed it." }
)

-- Delete all contents without affecting registers (void delete)
vim.keymap.set(
	"n",
	"<leader>vd",
	":%d _<CR>",
	{ desc = "Delete all file contents (void delete)", noremap = true, silent = true }
)

-- Replace all file contents with clipboard (void replace)
vim.keymap.set(
	"n",
	"<leader>vr",
	'gg"_dG"+p',
	{ desc = "Replace file with clipboard content", noremap = true, silent = true }
)

-- Map Ctrl+A to select all text and copy it
vim.api.nvim_set_keymap("n", "<C-a>", 'ggVG"+y', { noremap = true })
vim.api.nvim_set_keymap("v", "<C-a>", '<Esc>ggVG"+y', { noremap = true })
