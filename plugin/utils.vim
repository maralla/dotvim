function! Log(msg) abort
  call writefile([a:msg."\n"], '/tmp/vim-log', 'a')
endfunction


function! ShowSyn()
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
