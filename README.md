buffed
======

**buffed** is a trivial Vim buffer management plugin. Its main purpose
is to facilitate the deletion of no longer used buffers. It aims to have
no dependencies other a Vim/Neovim itself.

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
form of functions. Users should define key bindings to invoke them. A
sample configuration may look like this:
```vim
" Open buffer list in new window by pressing F3.
nnoremap <F3> :call g:BuffedShowBuffers('enew')<CR>
```
