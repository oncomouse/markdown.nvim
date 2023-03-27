# Oncomouse's markdown.nvim plugin

This plugin combines a few features from other plugins while removing features I don't use:

1. The ability to do syntax-aware join (`J` and `gJ`) and newline (`o` and `O`).
    - Newline supports extending block quotes and lists (both ordered and unordered).
    - Join will remove syntax when joining lines.
1. Smart detab: if `<C-d>` is pressed until all that remains at the front of the line is Markdown syntax (lists or block quotes), those will also be removed.
1. All of the motion commands from [vim-markdown](https://github.com/preservim/vim-markdown).

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

1. [ ] Binding to switch list type (from ordered to unordered).
1. [ ] Binding to recalculate numbering for ordered lists
2. [X] Detab properly renumbers ordered lists
3. [X] Tab binding to properly renumber ordered lists
3. [X] Increment numbers on new ordered list
4. [ ] Tab/detab with operator-pending support for renumbering
