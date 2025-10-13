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
                auto_integrations = true
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        'HiPhish/rainbow-delimiters.nvim',
        version = false,
        init = function()
            vim.g.rainbow_delimiters = {
                blacklist = { "vue" },
            }
        end,
    },

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
                "typescript",
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
                "cpp",
                "cuda",
                "vue",
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
                        ["afp"] = { query = "@parameter.outer", desc = "Select outer part of a function parameter" },
                        ["ifp"] = { query = "@parameter.inner", desc = "Select inner part of a function parameter" },
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
            keymaps = {
                useDefaults = true
            },
        },
    },
    {
        "windwp/nvim-ts-autotag",
        -- event = "LazyFile",
        opts = {},
    },
    -- Auto convert template strings
    {
        "axelvc/template-string.nvim",
        config = true,
    },

    -- Icons used by various plugins
    { "nvim-tree/nvim-web-devicons",         lazy = true },

    -- Manager for external tools (e.g. LSPs)
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            { "mason-org/mason.nvim",           opts = true },
            { "mason-org/mason-lspconfig.nvim", opts = true },
        },
        opts = {
            ensure_installed = {
                "basedpyright",
                "ruff",
                "lua_ls",
                "html",
                "rust_analyzer",
                "clangd",
                "vtsls",
                "vue_ls",
                "tailwindcss",
            },
        },
    },

    -- Setup LSPs
    {
        "neovim/nvim-lspconfig",
        keys = {
            { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action" },
            { "<leader>ln", vim.lsp.buf.rename,      desc = "Rename" },
            { "<leader>ld", vim.lsp.buf.definition,  desc = "Go to definition" },
            { "<leader>lr", vim.lsp.buf.references,  desc = "References" },
            {
                "<C-k>",
                function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
                desc = "Enable inlay hints"
            },
        },
        dependencies = {
            "folke/neodev.nvim",
        },
        init = function()
            local lspCapabilities = require('blink.cmp').get_lsp_capabilities()

            require("lspconfig").basedpyright.setup({
                capabilities = lspCapabilities,
                settings = {
                    basedpyright = {
                        disableOrganizeImports = true,
                        analysis = {
                            typeCheckingMode = "off",
                        },
                    }
                }
            })

            require("lspconfig").ruff.setup({
                -- Disable ruff as hover provider to avoid conflicts with pyright
                on_attach = function(client)
                    client.server_capabilities.hoverProvider = false
                end,
            })

            require("lspconfig").html.setup {
                capabilities = lspCapabilities,
                filetypes = { "html", "htmldjango" },
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = false
                end,
            }

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

            require("lspconfig").clangd.setup({
                capabilities = lspCapabilities,
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = false
                end,
            })

            vim.lsp.config("vtsls", {
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "typescript",
                    "typescriptreact",
                    "vue",
                },
                settings = {
                    reuse_client = true,
                    vtsls = {
                        tsserver = {
                            globalPlugins = {
                                {
                                    name = '@vue/typescript-plugin',
                                    location = vim.fn.stdpath 'data' ..
                                        '/mason/packages/vue-language-server/node_modules/@vue/language-server',
                                    languages = { 'vue' },
                                    configNamespace = 'typescript',
                                },
                            },
                        },
                    },
                },
            })

            vim.lsp.enable({ "vtsls", "tailwind_css", "vue_ls" })
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
                "<leader>lf",
                function() require("conform").format({ lsp_fallback = true }) end,
                desc = "Format",
            },
        },
        opts = {
            formatters_by_ft = {
                python = { "ruff_format", "ruff_organize_imports" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                vue = { "prettier" },

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
            signature = { enabled = true },
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
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup({})

            vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Add to Harpoon" })
            vim.keymap.set(
                "n",
                "<leader>hl",
                function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
                { desc = "Open Harpoon window" }
            )
            vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end,
                { desc = "Select Harpoon mark #1" })
            vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end,
                { desc = "Select Harpoon mark #2" })
            vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end,
                { desc = "Select Harpoon mark #3" })
            vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end,
                { desc = "Select Harpoon mark #4" })
        end
    },
    {
        "akinsho/bufferline.nvim",
        lazy = false,
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {
            options = {
                diagnostics = "nvim_lsp",
                separator_style = "slant",
                diagnostics_indicator = function(_, _, diagnostics_dict, _)
                    local s = " "
                    for e, n in pairs(diagnostics_dict) do
                        local sym = e == "error" and " "
                            or (e == "warning" and " " or " ")
                        s = s .. n .. sym
                    end
                    return s
                end
            },
        },
        keys = {
            { "<leader>bp", "<cmd>BufferLinePick<cr>",        desc = "Pick a tab" },
            { "<leader>bc", "<cmd>bdelete<cr>",               desc = "Close current tab" },
            { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other tabs" },
            { "<Tab>",      "<cmd>BufferLineCycleNext<cr>",   desc = "Next tab" },
            { "<S-Tab>",    "<cmd>BufferLineCyclePrev<cr>",   desc = "Previous tab" },
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
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix"
        },
    },
    {
        "sphamba/smear-cursor.nvim",
        opts = {},
    },
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        config = function()
            require('tiny-inline-diagnostic').setup({
                options = {
                    multilines = true,
                },
            })
            vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text
        end
    },

    -- File explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false,
        keys = {
            { "<leader>t", "<cmd>Neotree<cr>", desc = "Open file explorer" }
        },
        opts = {
            filesystem = {
                follow_current_file = {
                    enabled = true,
                },
                use_libuv_file_watcher = true,
            },
        },
    },


    -- Git integration
    {
        "lewis6991/gitsigns.nvim",
        opts = {},
    },
    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>g", "<cmd>LazyGit<cr>", desc = "LazyGit" }
        }
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
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = {},
    },
    -- Disable sort operator in favor of `mini.surround`
    { 'echasnovski/mini.operators', version = false, opts = { sort = { prefix = "", }, }, },
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
    {
        'nvim-mini/mini.surround',
        version = false,
        opts = {
            mappings = {
                add = "gsa",            -- Add surrounding in Normal and Visual modes
                delete = "gsd",         -- Delete surrounding
                find = "gsf",           -- Find surrounding (to the right)
                find_left = "gsF",      -- Find surrounding (to the left)
                highlight = "gsh",      -- Highlight surrounding
                replace = "gsr",        -- Replace surrounding
                update_n_lines = "gsn", -- Update `n_lines`
            },
        },
    },

    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            explorer = { enabled = true },
            image = { enabled = true },
            picker = { enabled = true },
        },
        keys = {
            { "<leader>e",  function() Snacks.explorer() end,       desc = "File Explorer" },

            { "<leader>ff", function() Snacks.picker.smart() end,   desc = "Smart Find Files" },
            { "<leader>fg", function() Snacks.picker.grep() end,    desc = "Grep" },
            { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
        }
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
