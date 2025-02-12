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
        config = function()
            require("catppuccin").setup({
                integrations = {
                    blink_cmp = true
                }
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    { 'HiPhish/rainbow-delimiters.nvim', version = false },

    -- Treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        main = "nvim-treesitter.configs",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
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
                "c",
                "cuda",
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["aca"] = { query = "@call.outer", desc = "Select outer part of a call" },
                        ["ica"] = { query = "@call.inner", desc = "Select inner part of a call" },
                        ["acl"] = { query = "@class.outer", desc = "Select outer part of a class" },
                        ["icl"] = { query = "@class.inner", desc = "Select inner part of a class" },
                        ["afd"] = { query = "@function.outer", desc = "Select outer part of a function" },
                        ["ifd"] = { query = "@function.inner", desc = "Select inner part of a function" },
                        ["afc"] = { query = "@call.outer", desc = "Select outer part of a function call" },
                        ["ifc"] = { query = "@call.inner", desc = "Select inner part of a function call" },
                        ["aa"] = { query = "@assignment.outer", desc = "Select outer part of a assignment" },
                        ["ia"] = { query = "@assignment.inner", desc = "Select inner part of a assignment" },
                    }
                }
            }
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = true,
    },
    {
        "chrisgrieser/nvim-various-textobjs",
        lazy = false,
        opts = {
            useDefaults = true,
            disabledDefaults = { "gc" },
        },
    },
    -- Auto convert template strings
    {
        "axelvc/template-string.nvim",
        config = true,
    },

    -- Icons used by various plugins
    { "nvim-tree/nvim-web-devicons",     lazy = true },

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
                "ruff",
                "lua_ls",
                "denols",
                "html",
                "rust_analyzer",
                "clangd"
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
            -- local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
            -- lspCapabilities.textDocument.completion.completionItem.snippetSupport = true
            local lspCapabilities = require('blink.cmp').get_lsp_capabilities()

            require("lspconfig").pyright.setup({
                capabilities = lspCapabilities,
                settings = {
                    pyright = {
                        disableOrganizeImports = true,
                    },
                    python = {
                        analysis = {
                            typeCheckingMode = "off",
                        }
                    }
                }
            })

            require("lspconfig").ruff.setup({
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

            require("lspconfig").rust_analyzer.setup({
                capabilities = lspCapabilities,
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy",
                        },
                    }
                }
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
                "<leader>l",
                function() require("conform").format({ lsp_fallback = true }) end,
                desc = "Format",
            },
        },
        opts = {
            formatters_by_ft = {
                python = { "ruff_format", "ruff_organize_imports" },
                c = { "clang-format" },

                -- Format codeblocks inside Markdown
                markdown = { "inject" },
            },
            format_on_save = {
                lsp_fallback = true,
            },
        },
    },

    {
        'saghen/blink.cmp',
        dependencies = 'rafamadriz/friendly-snippets',
        version = '*',
        opts = {
            keymap = { preset = 'super-tab' },

            appearance = {
                nerd_font_variant = 'mono'
            },
            signature = { enabled = true },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
            enabled = function()
                return not vim.tbl_contains({ "rip-substitute" }, vim.bo.filetype)
                    and vim.bo.buftype ~= "prompt"
                    and vim.b.completion ~= false
            end,
            completion = {
                menu = {
                    auto_show = function()
                        return not vim.tbl_contains({ '/', '?' }, vim.fn.getcmdtype())
                    end,
                },
            },
        },
        opts_extend = { "sources.default" }
    },


    -- Telescope for finding files, opening files, and grepping
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        version = false,
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (root dir)" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Search Project" },
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
        opts = {},
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
        },
        opts = {
            integrations = {
                diffview = true,
            },
        },
    },

    -- Virtual environment
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
        opts = {
            stay_on_this_version = true
        },
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
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "s",
                mode = { "n", "x", "o" },
                function() require("flash").jump() end,
                desc = "Flash"
            },
            {
                "S",
                mode = { "n", "x", "o" },
                function() require("flash").treesitter() end,
                desc = "Flash Treesitter"
            },
            {
                "r",
                mode = "o",
                function() require("flash").remote() end,
                desc = "Remote Flash"
            },
            {
                "R",
                mode = { "o", "x" },
                function() require("flash").treesitter_search() end,
                desc = "Treesitter Search"
            },
            {
                "<c-s>",
                mode = { "c" },
                function() require("flash").toggle() end,
                desc = "Toggle Flash Search"
            },
        },
    },

    -- Editing support
    { 'numToStr/Comment.nvim',               opts = {} },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl",    opts = {} },
    { 'echasnovski/mini.pairs',              version = false, opts = {} },
    { 'echasnovski/mini.operators',          version = false, opts = {} },
    {
        "chrisgrieser/nvim-rip-substitute",
        cmd = "RipSubstitute",
        opts = {},
        keys = {
            {
                "<leader>fs",
                function() require("rip-substitute").sub() end,
                mode = { "n", "x" },
                desc = " rip substitute",
            },
        },
    },
    {
        'MagicDuck/grug-far.nvim',
        config = function()
            require('grug-far').setup();
        end
    },
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
