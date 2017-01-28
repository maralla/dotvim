function! Log(msg) abort
py << EOF
import vim
with open('/tmp/vim-log', 'a') as f:
  f.write(vim.bindeval('a:')['msg'] + '\n')
EOF
endfunction
