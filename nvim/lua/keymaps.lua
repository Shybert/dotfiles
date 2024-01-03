-- Remapped text objects
vim.keymap.set("o", "ar", "a[")
vim.keymap.set("o", "ir", "i[")

vim.keymap.set("o", "ac", "a{")
vim.keymap.set("o", "ic", "i{")

vim.keymap.set("o", "aq", 'a"')
vim.keymap.set("o", "iq", 'i"')

vim.keymap.set("o", "az", "a'")
vim.keymap.set("o", "iz", "i'")

-- Let's keep that register clean!
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "c", '"_c')
vim.keymap.set("n", "dd", function()
    if vim.fn.getline(".") == "" then return '"_dd' end
    return "dd"
end, { expr = true })
