-- leader key
vim.g.mapleader = ";"

-- window navigation
vim.keymap.set("n", "<A-w><A-w>", ":wincmd w<CR>", { desc = "Switch to next window" })
vim.keymap.set("n", "<leader>f", ":NERDTreeFind<CR>", { desc = "Find file in NERDTree" })
vim.keymap.set("n", "<leader>d", ":NERDTreeToggle<CR>", { desc = "Toggle NERDTree" })


-- GUI font
vim.opt.guifont = "Consolas:h10"

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
