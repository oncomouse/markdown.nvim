# Oncomouse's markdown.nvim plugin

This plugin combines a few features from other plugins while removing features I don't use:

1. The ability to do syntax-aware join (`J` and `gJ`) and newline (`o` and `O`).
    - Newline supports extending block quotes and lists (both ordered and unordered).
    - Join will remove syntax when joining lines.
1. Smart detab: if `<C-d>` is pressed until all that remains at the front of the line is Markdown syntax (lists or block quotes), those will also be removed.
1. All of the motion commands from [vim-markdown](https://github.com/preservim/vim-markdown).

## Todo

1. [ ] Binding to switch list type (from ordered to unordered).
