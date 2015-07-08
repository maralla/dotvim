" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0
source ~/.vim/config/func.vim
source ~/.vim/config/type.vim
source ~/.vim/config/set.vim

if 0 | endif

if has('vim_starting')
  if &compatible
    set nocompatible
  endif

  set runtimepath+=~/.vim/bundle/neobundle.vim
endif

call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

source ~/.vim/config/bundle.vim

" window killer
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>

if neobundle#is_sourced('vim-dispatch')
  nnoremap <leader>tag :Dispatch ctags -R<cr>
endif

call neobundle#end()

let g:solarized_termcolors=256
try
  colorscheme solarized
catch /^Vim\%((\a\+)\)\=:E185
endtry

set t_Co=256
set background=dark

filetype plugin indent on
syntax enable

NeoBundleCheck

" load bundle settings
source ~/.vim/config/settings.vim

" highlights
hi SignColumn ctermbg=235
