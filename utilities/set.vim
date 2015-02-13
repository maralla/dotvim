" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

set timeoutlen=300                              " mapping timeout
set ttimeoutlen=50                              " keycode timeout
set mousehide                                   " hide when characters are typed
set history=1000                                " number of command lines to remember
set ttyfast                                     " assume fast terminal connection
set viewoptions=folds,options,cursor,unix,slash " unix/windows compatibility
set encoding=utf-8                              " set encoding for text
set clipboard=unnamed                           " sync with OS clipboard
set hidden                                      " allow buffer switching without saving
set autoread                                    " auto reload if file saved externally
set fileformats+=mac                            " add mac to auto-detection of file format line endings
set nrformats-=octal                            " always assume decimal numbers
set showcmd
set tags=tags;/
set showfulltag
set modeline
set modelines=5
set exrc

" whitespace
set backspace=indent,eol,start                     " allow backspacing everything in insert mode
set autoindent                                     " automatically indent to match adjacent lines
set expandtab                                      " spaces instead of tabs
set smarttab                                       " use shiftwidth to enter tabs
set tabstop=4                                      " number of spaces per tab for display
set softtabstop=4                                  " number of spaces per tab in insert mode
set shiftwidth=4                                   " number of spaces when indenting
set list                                           " highlight whitespace
set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
set shiftround
set linebreak

set scrolloff=1                                    " always show content after scroll
set scrolljump=5                                   " minimum number of lines to scroll
set display+=lastline
set wildmenu                                       " show list for autocomplete
set wildmode=list:longest,full
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store

set splitbelow
set splitright

set showmatch    " automatically highlight matching braces/brackets/etc.
set matchtime=2  " tens of a second to show matching parentheses
set number
set lazyredraw
set laststatus=2
set noshowmode
set nofoldenable " disable folds by default

" disable sounds
set noerrorbells
set novisualbell
set t_vb=

" searching
set hlsearch   " highlight searches
set incsearch  " incremental searching
set ignorecase " ignore case for searching
set smartcase  " do case-sensitive if there's a capital letter
if executable('ack')
    set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
    set grepformat=%f:%l:%c:%m
endif
if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
endif

set cursorline
autocmd WinLeave * setlocal nocursorline
autocmd WinEnter * setlocal cursorline
set colorcolumn=80

if has('conceal')
  set conceallevel=1
  set listchars+=conceal:Δ
endif

if has('gui_running')
  " open maximized
  set lines=999 columns=9999
  if s:is_windows
    autocmd GUIEnter * simalt ~x
  endif

  set guioptions+=t " tear off menu items
  set guioptions-=T " toolbar icons

  if s:is_macvim
    set gfn=Ubuntu_Mono:h14
    set transparency=2
  endif

  if s:is_windows
    set gfn=Ubuntu_Mono:h10
  endif

  if has('gui_gtk')
    set gfn=Ubuntu\ Mono\ 11
  endif
else
  if $TERM_PROGRAM == 'iTerm.app'
    " different cursors for insert vs normal mode
    if exists('$TMUX')
      let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
      let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    else
      let &t_SI = "\<Esc>]50;CursorShape=1\x7"
      let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    endif
  endif
endif

" persistent undo
if exists('+undofile')
  set undofile
  set undodir=~/.vim/.cache/undo
endif

" backups
set backup
set backupdir=~/.vim/.cache/backup

" swap files
set directory=~/.vim/.cache/swap
set noswapfile

call EnsureExists('~/.vim/.cache')
call EnsureExists(&undodir)
call EnsureExists(&backupdir)
call EnsureExists(&directory)

if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

let mapleader = ","
let g:mapleader = ","

" mappings
vmap <leader>s :sort<cr>
nnoremap <leader>w :w<cr>
map <leader>pp :set invpaste<CR>:set paste?<CR>
nmap <silent> <leader>,/ :nohlsearch<CR>
cmap w!! w !sudo tee % >/dev/null

map <leader>tn :tabnew<CR>
map <leader>tc :tabclose<CR>
nnoremap <S-H> :tabprev<CR>
nnoremap <S-L> :tabnext<CR>
nnoremap <down> :tabprev<CR>
nnoremap <left> :bprev<CR>
nnoremap <right> :bnext<CR>
nnoremap <up> :tabnext<CR>
nnoremap <leader>v <C-w>v<C-w>l
nnoremap <leader>s <C-w>s
nnoremap <leader>vsa :vert sba<cr>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

inoremap jk <esc>
inoremap kj <esc>

if mapcheck('<space>/') == ''
  nnoremap <space>/ :vimgrep //gj **/*<left><left><left><left><left><left><left><left>
endif

nnoremap q: q:i
nnoremap q/ q/i
nnoremap q? q?i

nnoremap zr zr:echo &foldlevel<cr>
nnoremap zm zm:echo &foldlevel<cr>
nnoremap zR zR:echo &foldlevel<cr>
nnoremap zM zM:echo &foldlevel<cr>

nnoremap <silent> j gj
nnoremap <silent> k gk

nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz

vnoremap < <gv
vnoremap > >gv

" reselect last paste
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" find current word in quickfix
nnoremap <leader>fw :execute "vimgrep ".expand("<cword>")." %"<cr>:copen<cr>

" find last search in quickfix
nnoremap <leader>ff :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Adjust viewports to the same size
map <Leader>= <C-w>=

" make Y consistent with C and D. See :help Y.
nnoremap Y y$

" hide annoying quit message
nnoremap <C-c> <C-c>:echo<cr>


" quick buffer open
nnoremap gb :ls<cr>:e #

" general
nmap <leader>l :set list! list?<cr>

map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" helpers for profiling
nnoremap <silent> <leader>DD :exe ":profile start profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
nnoremap <silent> <leader>DP :exe ":profile pause"<cr>
nnoremap <silent> <leader>DC :exe ":profile continue"<cr>
nnoremap <silent> <leader>DQ :exe ":profile pause"<cr>:noautocmd qall!<cr>

command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>


autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \  exe 'normal! g`"zvzz' |
  \ endif
