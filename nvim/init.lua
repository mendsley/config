-- leader key
vim.g.mapleader = ";"

-- window navigation
vim.keymap.set("n", "<A-w><A-w>", ":wincmd w<CR>", { desc = "Switch to next window" })
vim.keymap.set("n", "<leader>f", ":NERDTreeFind<CR>", { desc = "Find file in NERDTree" })
vim.keymap.set("n", "<leader>d", ":NERDTreeToggle<CR>", { desc = "Toggle NERDTree" })

-- GUI font
if vim.fn.has("mac") == 1 then
    vim.opt.guifont = "Menlo:h11"
else
    vim.opt.guifont = "Consolas:h10"
end

-- tabstops
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.cindent = true

-- line numbers
vim.opt.number = true

-- disable persistent search highlight
vim.opt.hlsearch = false

-- disable italic strings
--vim.api.nvim_set_hl(0, "String", { gui = "NONE", cterm = "NONE" })

-- visible whitespace
vim.opt.list = true
vim.opt.listchars = {
	tab = "▸ ",
	trail = "·",
	space = "·",
	nbsp = "␣"
}

-- neovide specific
if vim.g.neovide then
	-- disable cursor animations
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_cursor_trail_size = 0
	vim.g.neovide_cursor_anialiasing = false
	vim.g.neovide_cursor_vfx_mode = ""

	-- font rendering options
	vim.g.neovide_font_ligatures = true
	vim.g.neovide_font_weight = "Normal"
	vim.g.neovide_font_style = "Normal"
end

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- steup lazy.nvim
require("lazy").setup({
	{ "nuvic/flexoki-nvim", name = "flexoki" },
	{ "preservim/nerdtree" },
	{ "rebelot/kanagawa.nvim" },

	-- LSP Support
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "gopls", "clangd" },
				automatic_installation = true,
			})
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				mapping = {
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
				},
			})
		end,
	},
})

-- default colorscheme
vim.cmd([[colorscheme kanagawa-wave]])

-- LSP configuration (Neovim 0.11+ native API)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.mod", "go.work", ".git" },
	capabilities = capabilities,
	settings = {
		gopls = {
			analyses = { unusedparams = true },
			staticcheck = true,
		},
	},
})

vim.lsp.config("clangd", {
	cmd = { "clangd", "--background-index", "--clang-tidy" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
	capabilities = capabilities,
})

vim.lsp.enable({ "gopls", "clangd" })

-- LSP keymaps via LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf, noremap = true, silent = true }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
		vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
	end,
})
