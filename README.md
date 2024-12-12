buffed
======

**buffed** is a trivial Neovim buffer management plugin. Its main
purpose is to facilitate the deletion of no longer used buffers, but it
can also be used to switch buffers. It aims to have no dependencies
other than Neovim itself.

Installation
------------
Installation typically happens by means of a plugin manager. For
[`Vundle`][vundle] the configuration could look like this:
```vim
call vundle#begin('~/.config/nvim/bundle')
...
Plugin 'd-e-s-o/buffed' "<---- relevant line
...
call vundle#end()
```

Configuration
-------------
As is common for plugins, **buffed** exposes its functionality in the
form of mainly one function, `BuffedShowBuffers`. Users should define a
key binding to invoke it. A sample Lua configuration looks like this:
```lua
-- Open buffer list in new window by pressing F3.
vim.keymap.set('n', '<F3>', ':lua require("buffed").BuffedShowBuffers()<CR>', {noremap = true})
```

[vundle]: https://github.com/VundleVim/Vundle.vim
