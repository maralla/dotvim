func! s:setup(width)
  exec 'normal! ' . a:width . "\<C-w>|"
  setlocal buftype=nofile
  setlocal ft=__margin__
  setlocal fillchars=vert:\ 
  hi VertSplit guibg=NONE
  setlocal nocursorline
  setlocal signcolumn=no
  setlocal statusline=
  setlocal bufhidden=wipe
  setlocal nonumber
  setlocal nobuflisted
  setlocal noswapfile
  let lines = repeat([""], winheight(0))
  normal! ,$d
  setlocal modifiable
  setlocal noreadonly
  call append(0, lines)
  setlocal readonly
  setlocal nomodifiable
endfunc


func! text#split(width)
  set signcolumn=no
  " left
  topleft vnew __margin__
  call s:setup(a:width)
  " right
  botright vnew __margin__
  call s:setup(a:width)
  call feedkeys("\<c-w>h")
endfunc
