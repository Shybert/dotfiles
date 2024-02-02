require("options")
require("keymaps")

-- Install Lazy plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyIsInstalled = vim.loop.fs_stat(lazypath)
if not lazyIsInstalled then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

local plugins = {
    -- Color scheme
    {
        "catppuccin/nvim",
        lazy = false,
        priority = 1000,
        config = function() vim.cmd.colorscheme("catppuccin") end,
    },
    -- Treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        main = "nvim-treesitter.configs",
        opts = {
            highlight = { enable = true },
            indent = { enable = true },
            ensure_installed = {
                "json",
                "javascript",
                "bash",
                "css",
                "csv",
                "dockerfile",
                "fish",
                "gitignore",
                "html",
                "htmldjango",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "rust",
                "scss",
                "ssh_config",
                "toml",
                "yaml",
                "vim",
            }
        },
    },
    {
        "chrisgrieser/nvim-various-textobjs",
        lazy = false,
        opts = {
            useDefaultKeymaps = true,
            disabledKeymaps = { "gc" },
        },
    },

    -- Icons used by various plugins
    { "nvim-tree/nvim-web-devicons",         lazy = true },

    -- Manager for external tools (e.g. LSPs)
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            { "williamboman/mason.nvim",           opts = true },
            { "williamboman/mason-lspconfig.nvim", opts = true },
        },
        opts = {
            ensure_installed = {
                "pyright",
                "ruff-lsp",
                "lua_ls",
                "denols",
                "html",
                "typst_lsp",
                "rust_analyzer",
                -- "taplo", -- LSP for toml (for pyproject.toml files)
            },
        },
    },

    -- Setup LSPs
    {
        "neovim/nvim-lspconfig",
        keys = {
            { "<leader>c",  vim.lsp.buf.code_action, desc = "Code Action" },
            { "<leader>cr", vim.lsp.buf.rename,      desc = "Rename" },
        },
        dependencies = {
            "folke/neodev.nvim",
        },
        init = function()
            local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
            lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

            require("lspconfig").pyright.setup({
                capabilities = lspCapabilities,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "off"
                        }
                    }
                }
            })

            require("lspconfig").ruff_lsp.setup({
                -- Disable ruff as hover provider to avoid conflicts with pyright
                on_attach = function(client)
                    client.server_capabilities.hoverProvider = false
                end,
            })

            require("lspconfig").denols.setup {
                capabilities = lspCapabilities,
            }

            require("lspconfig").html.setup {
                capabilities = lspCapabilities,
                filetypes = { "html", "htmldjango" },
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = false
                end,
            }

            -- -- setup taplo with completion capabilities
            -- require("lspconfig").taplo.setup({
            -- 	capabilities = lspCapabilities,
            -- })

            require("lspconfig").lua_ls.setup({
                capabilities = lspCapabilities,
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        diagnostics = {
                            globals = {
                                "vim",
                            },
                        },
                        workspace = {
                            library = {
                                vim.env.VIMRUNTIME,
                            }
                        }
                    }
                }
            })

            require("lspconfig").typst_lsp.setup({
                capabilities = lspCapabilities,
            })

            require("lspconfig").rust_analyzer.setup({
                capabilities = lspCapabilities,
            })
        end,
    },

    -- LSP preview
    {
        "rmagatti/goto-preview",
        opts = {},
        keys = {
            {
                "<leader>cp",
                function() require("goto-preview").goto_preview_definition() end,
                desc = "Preview definition",
            },
            {
                "<leader>cP",
                function() require("goto-preview").close_all_win() end,
                desc = "Close preview definition windows",
            },
        }
    },

    -- Formatting
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        keys = {
            {
                "<leader>f",
                function() require("conform").format({ lsp_fallback = true }) end,
                desc = "Format",
            },
        },
        opts = {
            formatters_by_ft = {
                python = { "ruff" },

                -- Format codeblocks inside Markdown
                markdown = { "inject" },
            },
            format_on_save = {
                lsp_fallback = true,
            },
        },
    },

    -- Snippets
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        event = "VeryLazy",
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip").filetype_extend("htmldjango", { "django" })
        end
    },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",

            -- Snippets
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert({
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
                    ["<s-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<c-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }
            })
        end,
    },

    -- Typst
    {
        "kaarmu/typst.vim",
        ft = "typst",
        lazy = false,
    },

    -- Telescope for finding files, opening files, and grepping
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        version = false,
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope git_files<cr>", desc = "Find Files (root dir)" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search Project" },
        },
        opts = {
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case"
                }
            }
        }
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
            require('telescope').load_extension('fzf')
        end
    },

    -- Diagnostics
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
        keys = {
            { "<leader>x", "<cmd>Trouble<cr>", desc = "Open diagnostics window" },
        },
    },

    -- UI
    {
        "akinsho/bufferline.nvim",
        lazy = false,
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {
            options = {
                diagnostics = "nvim_lsp"
            },
        },
        keys = {
            { "<leader>bp", "<cmd>BufferLinePick<cr>",      desc = "Pick a tab" },
            { "<leader>bc", "<cmd>bdelete<cr>",             desc = "Close current tab" },
            { "<Tab>",      "<cmd>BufferLineCycleNext<cr>", desc = "Next tab" },
            { "<S-Tab>",    "<cmd>BufferLineCyclePrev<cr>", desc = "Previous tab" },
        },
    },
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                icons_enabled = true,
                theme = 'onedark',
                component_separators = '|',
                section_separators = '',
            },
        },
    },
    {
        'Aasim-A/scrollEOF.nvim',
        event = { 'CursorMoved', 'WinScrolled' },
        opts = {},
    },
    {
        'stevearc/dressing.nvim',
        opts = { input = { enabled = true }, },
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {},
        keys = {
            { "<leader>t", "<cmd>NvimTreeToggle<cr>", desc = "Open file explorer" },
        }
    },

    -- Git integration
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, { expr = true })

                map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, { expr = true })

                -- Actions
                map('n', '<leader>hs', gs.stage_hunk)
                map('n', '<leader>hr', gs.reset_hunk)
                map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
                map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
                map('n', '<leader>hS', gs.stage_buffer)
                map('n', '<leader>hu', gs.undo_stage_hunk)
                map('n', '<leader>hR', gs.reset_buffer)
                map('n', '<leader>hp', gs.preview_hunk)
                map('n', '<leader>hb', function() gs.blame_line { full = true } end)
                map('n', '<leader>tb', gs.toggle_current_line_blame)
                map('n', '<leader>hd', gs.diffthis)
                map('n', '<leader>hD', function() gs.diffthis('~') end)
            end
        },
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",

            "nvim-telescope/telescope.nvim",
        },
        config = true,
        keys = {
            { "<leader>g", "<cmd>Neogit<cr>" },
        }
    },

    -- Virtual environment
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
        opts = {},
        keys = {
            { "<leader>vs", "<cmd>VenvSelect<cr>" },
            { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
        }
    },

    -- Session management
    {
        "olimorris/persisted.nvim",
        config = true,
        opts = {
            autoload = true,
            use_git_branch = true,
        },
    },

    -- Movement
    {
        "karb94/neoscroll.nvim",
        config = true,
    },
    {
        "ggandor/leap.nvim",
        config = function()
            require("leap").create_default_mappings()
        end,
    },

    -- Editing support
    { 'numToStr/Comment.nvim',               opts = {} },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl",    opts = {} },
    { 'echasnovski/mini.pairs',              version = false, opts = {} },
}

require("lazy").setup(plugins)

-- Highlight on Yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- Automatically select Python virtual environment after loading session
vim.api.nvim_create_autocmd({ "User" }, {
    desc = 'Automatically select virtual environment when loading a session',
    pattern = 'PersistedLoadPre',
    callback = function()
        local venv = vim.fn.findfile('pyproject.toml', vim.fn.getcwd() .. ';')
        if venv ~= '' then
            require('venv-selector').retrieve_from_cache()
        end
    end,
})
