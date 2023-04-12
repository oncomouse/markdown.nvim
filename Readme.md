# Oncomouse's markdown.nvim plugin

This plugin combines a few features from other plugins while removing features I don't use:

1. The ability to do syntax-aware join (`J` and `gJ`) and newline (`o` and `O`).
    * Newline supports extending block quotes and lists (both ordered and unordered).
    * Join will remove syntax when joining lines.
2. Smart detab:
    * In insert mode, `<C-d>` with no whitespace will delete list marker
    * In normal and visual mode, `<` and `<<` with no whitespace will delete list marker
3. All of the motion commands from [vim-markdown](https://github.com/preservim/vim-markdown).
4. Switch list type:
    * In insert mode, `<C-Z>` will switch list type for the current line
    * In normal mode, `<leader>mss` will switch list type for the current list
        * `<leader>ms` will use `operatorfunc` to switch list type for a given motion
    * In visual mode, `<leader>ms` will switch highlighted lines
5. Renumber:
    * In normal mode, `<leader>mn` will renumber an ordered list

## Configuring

Running `require("markdown").setup()` will create the necessary mappings in any buffer. By default, this loads for all markdown files, but you could use autocommands or other ftplugins to load the mappings elsewhere.

Several variables control the plugin's behavior:

* `vim.g.markdown_nvim_modules` -- Define the modules to load (default: `{ "markdown.detab", "markdown.join", "markdown.movements", "markdown.newline", "markdown.renumber", "markdown.switch", }`)
* `vim.g.markdown_nvim_unordered_default` -- Define the unordered token to use when switching ordered lists to unordered (default: `*`)
    * `vim.b.markdown_nvim_unordered_default` -- Set for individual buffers
* `vim.g.markdown_nvim_do_not_set_default_maps` -- Set to `true` or `1` to prevent the creation of default mappings.
    * `vim.b.markdown_nvim_do_not_set_default_maps` -- Disable default maps for an individual buffer

## Autopairs Support for markdown.nvim

This plugin does not insert list or blockquote characters on newline. Lists can be managed using [autolist.nvim](https://github.com/gaoDean/autolist.nvim); block quotes might be extending using any of the available autopairs plugins.

I use [lexima.vim](https://github.com/cohama/lexima.vim) for autopairs, and the following rules supplement this plugin:

```lua
-- Blockquotes:
vim.fn["lexima#add_rule"]({
    char = "<BS>",
    input = "<BS><BS>",
    at = [[^> \%#]],
    filetype = "markdown",
})
vim.fn["lexima#add_rule"]({
    char = "<CR>",
    at = [[^> .\+\%#$]],
    input = "<CR>> ",
    filetype = "markdown",
})
vim.fn["lexima#add_rule"]({
    char = "<CR>",
    at = [[^> \%#$]],
    input = "<BS><BS><CR>",
    filetype = "markdown",
})
vim.fn["lexima#add_rule"]({
    char = ">",
    input = "> ",
    at = [[^\%#]],
    filetype = "markdown",
})
-- Unordered Lists:
vim.fn["lexima#add_rule"]({
    char = "<CR>",
    at = [[^\s*\([*-]\).*\%#$]],
    filetype = "markdown",
    with_submatch = true,
    input = [[<CR>\1 ]],
    except = [[^\s*\([*-]\) \%#$]],
})
vim.fn["lexima#add_rule"]({
    char = "<CR>",
    at = [[^\s*[*-] \%#$]],
    filetype = "markdown",
    input = "<Home><C-O>D<CR>",
})
vim.fn["lexima#add_rule"]({
    char = "<BS>",
    at = [[^\(\s*\)[*-] \%#$]],
    filetype = "markdown",
    with_submatch = true,
    input = [[<Home><C-O>D\1]],
})
-- Ordered Lists (including automatic increment):
vim.fn["lexima#add_rule"]({
    char = "<CR>",
    at = [[^\s*\([0-9]\+\)\..*\%#$]],
    filetype = "markdown",
    with_submatch = true,
    input = [[<CR>\1. <Home><C-O>:exec "normal! \<c-a\>" "$"<CR>]],
    except = [[^\s*\([0-9]\)\. \%#$]],
})
vim.fn["lexima#add_rule"]({
    char = "<CR>",
    at = [[^\s*[0-9]\+\. \%#$]],
    filetype = "markdown",
    input = "<Home><C-O>D<CR>",
})
vim.fn["lexima#add_rule"]({
    char = "<BS>",
    at = [[^\(\s*\)[0-9]\+\. \%#$]],
    filetype = "markdown",
    with_submatch = true,
    input = [[<Home><C-O>D\1]],
})
```

## Todo

1. [X] Binding to switch list type (from ordered to unordered).
2. [X] Binding to recalculate numbering for ordered lists
3. [X] Detab properly renumbers ordered lists
4. [X] Tab binding to properly renumber ordered lists
5. [X] Increment numbers on new ordered list
6. [X] Tab support for renumbering in normal mode (`>>`)
7. [X] Tab/detab with operator-pending support (`>`) for renumbering
8. [X] Delete module operator-pending support
