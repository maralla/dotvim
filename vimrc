" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

source ~/.vim/utilities/func.vim
source ~/.vim/utilities/type.vim


if !1 | finish | endif


if has('vim_starting')
  set nocompatible
  set all& "reset everything to their defaults
  set rtp+=~/.vim/bundle/neobundle.vim
endif

call neobundle#begin(expand('~/.vim/bundle/'))

source ~/.vim/utilities/set.vim
source ~/.vim/utilities/bundle.vim

" window killer
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>

if neobundle#is_sourced('vim-dispatch')
  nnoremap <leader>tag :Dispatch ctags -R<cr>
endif

call neobundle#end()


colorscheme solarized
set t_Co=256
set background=dark
" hi! StatusLineNC cterm=none

filetype plugin indent on
syntax enable

NeoBundleCheck
