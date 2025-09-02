-- vim.cmd.colorscheme('lunaperche')
vim.cmd.colorscheme('habamax')

local opt = vim.opt
local g = vim.g

-- Basic settings
opt.number = true
opt.relativenumber = true
opt.wrap = false        -- disable line wrapping
-- opt.ruler = false
opt.cursorline = true   -- highlight the current line
opt.scrolloff = 10      -- autoscroll when going up or down
opt.sidescrolloff = 8   -- keep 9 columns left/right of the cursor

-- Indenting
opt.expandtab = true
opt.shiftwidth = 4
opt.smartindent = true
opt.tabstop = 4
opt.softtabstop = 4

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

opt.splitright = true
opt.splitbelow = true

-- visual settings
opt.termguicolors = true -- enable rgb colors
opt.showmatch = true    -- highlight matching brackets
opt.cmdheight = 1       -- command line height
opt.completeopt = "menuone,noinsert,noselect,popup"   -- completion options
opt.showmode = false    -- don't show mode in command line

-- File handling
opt.backup = false      -- don't create backup files
opt.writebackup = false -- don't create backup before writing
opt.swapfile = false    -- don't create swap files
opt.undofile = true     -- persistent undo
opt.undodir = vim.fn.expand("~/.vim/undodir")   -- undo directory
opt.autoread = true     -- auto reload files that have changed outside vim
opt.autowrite = false   -- don't autosave

-- Behavior settings
opt.hidden = true       -- Allow hidden buffers
opt.autochdir = false   -- don't autochage the directory
opt.iskeyword:append("-")   -- treat dash as part of word
opt.path:append("**")       -- include subdirectories in search
opt.selection = "exclusive" -- selection behavior
opt.mouse = "a"             -- enable mouse
opt.clipboard:append("unnamedplus") -- use system clipboard
opt.modifiable = true       -- allow buffer modifications
opt.encoding = "UTF-8"      -- Set encoding

-- syntax highlighting
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

-- Leader key
g.mapleader = " " -- Space as the leader key
g.maplocalleader = " "
vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })

-- Splitting and resizing
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" } )
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" } )

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" } )
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" } )
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" } )
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" } )

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" } )
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" } )

-- Quick file navigation
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file browser" } )
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find file" } )

-- Quick config editing
vim.keymap.set("n", "<leader>rc", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" } )

-- Show lsp hover
vim.keymap.set("n", "<leader>h", ":lua vim.diagnostic.open_float()<CR>", { desc = "Show LSP hover" } )

-- CTRL-space to trigger LSP completion, in addition to <C-x><C-o>
vim.keymap.set("i", "<C-space>", function()
    vim.lsp.completion.get()
end)

-- Set filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "lua", "python" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "javascript", "typescript", "json", "html", "css" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- CLI completion
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })


-- performance improvements
opt.redrawtime = 10000
opt.maxmempattern = 20000

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end


-- STATUS LINE --
local function git_branch()
    local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
    if branch ~= "" then
        return "  " .. branch .. " "
    end
    return ""
end

local function file_type()
    local ft = vim.bo.filetype
    local icons = {
        lua = "[LUA]",
        python = "[PY]",
        javascript = "[JS]",
        html = "[HTML]",
        css = "[CSS]",
        json = "[JSON]",
        markdown = "[MD]",
        vim = "[VIM]",
        sh = "[SH]",
    }
    if ft == "" then
        return " "
    end
    return (icons[ft] or ft)
end

local function lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        return "  LSP "
    end
    return ""
end

-- Word count for text files
local function word_count()
    local ft = vim.bo.filetype
    if ft == "markdown" or ft == "text" or ft == "tex" then
        local words = vim.fn.wordcount().words
        return "  " .. words .. " words "
    end
    return ""
end

-- File size
local function file_size()
    local size = vim.fn.getfsize(vim.fn.expand('%'))
    if size < 0 then return "" end
    if size < 1024 then
        return size .. "B "
    elseif size < 1024 * 1024 then
        return string.format("%.1fK", size / 1024)
    else
        return string.format("%.1fM", size / 1024 / 1024)
    end
end

-- Mode indicators with icons
local function mode_icon()
    local mode = vim.fn.mode()
    local modes = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        ["\22"] = "V-BLOCK",  -- Ctrl-V
        c = "COMMAND",
        s = "SELECT",
        S = "S-LINE",
        ["\19"] = "S-BLOCK",  -- Ctrl-S
        R = "REPLACE",
        r = "REPLACE",
        ["!"] = "SHELL",
        t = "TERMINAL"
    }
    return modes[mode] or "  " .. mode:upper()
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size
_G.lsp_status = lsp_status

vim.cmd([[
highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
    vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
        callback = function()
            vim.opt_local.statusline = table.concat {
                "  ",
                "%#StatusLineBold#",
                "%{v:lua.mode_icon()}",
                "%#StatusLine#",
                " │ %f %h%m%r",
                "%{v:lua.git_branch()}",
                " │ ",
                "%{v:lua.file_type()}",
                " | ",
                "%{v:lua.file_size()}",
                " | ",
                "%{v:lua.lsp_status()}",
                "%=",                     -- Right-align everything after this
                "%l:%c  %P ",             -- Line:Column and Percentage
            }
        end
    })
    vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

    vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
        callback = function()
            vim.opt_local.statusline = "  %f %h%m%r │ %{v:lua.file_type()} | %=  %l:%c   %P "
        end
    })
end

setup_dynamic_statusline()


-- LSP --

---- Function to find project root
local function find_root(patterns)
    local path = vim.fn.expand('%:p:h')
    local root = vim.fs.find(patterns, { path = path, upward = true })[1]
    return root and vim.fn.fnamemodify(root, ':h') or path
end


-- python lsp
local function setup_python_lsp()
    vim.lsp.start({
        name = 'pylsp',
        cmd = { 'pylsp' },
        filetypes = { 'python'},
        root_dir = find_root({ 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git'}),
        settings = {
            pylsp = {
                plugins = {
                    pycodestyle = {
                        enabled = false
                    },
                    rope_completion = {
                        enabled = true
                    }
                }
            }
        },
        on_attach = function(client, bufnr)
            vim.lsp.completion.enable(true, client.id, bufnr, {
                autotrigger = true,
                convert = function(item)
                    return { abbr = item.label:gsub('%b()', '') }
                end
            })
        end
    })
end


vim.api.nvim_create_autocmd('FileType', {
    pattern = 'python',
    callback = setup_python_lsp,
    desc = 'Start Python LSP'
})


local function setup_js_lsp()
    vim.lsp.start({
        name = 'jsls',
        cmd = { 'quick-lint-js', '--lsp-server' },
        filetypes = { 'javascript', 'typescript' },
        root_dir = find_root({ 'package.json', 'jsconfig.json', '.git'}),
        single_file_support = true,
        on_attach = function(client, bufnr)
            vim.lsp.completion.enable(true, client.id, bufnr, {
                autotrigger = true,
                convert = function(item)
                    return { abbr = item.label:gsub('%b()', '') }
                end
            })
        end
    })
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'typescript' },
    callback = setup_js_lsp,
    desc = 'Start JS LSP',
})


-- setup treesitter for better syntax highlighting
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "javascript", "json", "lua", "python", "sql", "go", "rust", "bash", "yaml", "toml", "dockerfile", "ini", "markdown" },
  highlight = { enable = true },
}
-- vim.api.nvim_set_hl(0, "@tag", { fg = "#ff8800" })
