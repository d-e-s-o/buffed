" buffed.vim

" Copyright (C) 2021-2022 Daniel Mueller <deso@posteo.net>
" SPDX-License-Identifier: GPL-3.0-or-later

" The code is based on `quickBuf`, with a couple of customization.

command! BuffedOpenBuffer execute "normal ^:bw! | buffer!\<c-r>\<c-w>\<CR>"
command! BuffedDeleteBuffer execute "normal ^:set modifiable | bw!\<c-r>\<c-w> | delete | set nomodifiable\<CR>"

function! g:BuffedShowBuffers(winType)
  set modifiable
  " Redirect the buffers command output to the bufvar variable.
  redir! => bufvar
    " Run the buffer command to and output via redirection to the
    " bufvar variable.
    silent buffers!
  redir END
  " Open in a new window or a new tab for display.
  execute a:winType
  " Paste the buffer list to the new buffer/tab.
  0put = bufvar
  " Delete the empty last and first lines and go to first line.
  " 'keepjumps' Command modifier prevents modification of jump history.
  keepjumps $d
  keepjumps 1d
  set nomodifiable
  " Add a mapping to Enter to open the buffer on the current line.
  nnoremap <buffer> <Enter> :BuffedOpenBuffer<CR>
  " Add a mapping to delete the buffer on the current line.
  nnoremap <buffer> d :BuffedDeleteBuffer<CR>
  " Add a mapping to quit.
  nnoremap <buffer> q :bw!<CR>
endfunction
