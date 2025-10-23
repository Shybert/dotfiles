-- Keep cursor in the middle of the screen when jumping up and down
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- Let's keep that register clean!
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "c", '"_c')
vim.keymap.set("n", "dd", function()
    if vim.fn.getline(".") == "" then return '"_dd' end
    return "dd"
end, { expr = true })

-- Remove highlights and clear command line with Escape in normal mode
vim.keymap.set("n", "<Esc>", ":nohl<CR>:echo<CR>")

-- Easier saving
vim.keymap.set("n", "<C-s>", ":update<cr>")
vim.keymap.set("i", "<C-s>", "<C-o>:update<cr>")

-- Multi-cursor, but better?
vim.keymap.set("n", "<C-n>", "*Ncgn")

-- Better j/k behavior with wrapped lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
