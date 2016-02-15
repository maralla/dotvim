" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

" utils {{{
function! Preserve(command)
  " preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the business:
  execute a:command
  " clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

function! StripTrailingWhitespace()
  call Preserve("%s/\\s\\+$//e")
endfunction

function! EnsureExists(path)
  if !isdirectory(expand(a:path))
    call mkdir(expand(a:path))
  endif
endfunction

function! CloseWindowOrKillBuffer()
  let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))

  " never bdelete a nerd tree
  if matchstr(expand("%"), 'NERD') == 'NERD'
    wincmd c
    return
  endif

  if number_of_windows_to_this_buffer > 1
    wincmd c
  else
    bdelete
  endif
endfunction
" }}}

" types {{{
autocmd BufNewFile,BufRead *.json setfiletype json
autocmd BufNewFile,BufRead *.jinja setfiletype jinja
autocmd BufNewFile,BufRead *.pyx,*.pxi setfiletype cython
autocmd BufNewFile,BufRead *.sls setfiletype sls
autocmd BufNewFile,BufRead *.h setfiletype c
autocmd FileType css,less,javascript,json,html,php,puppet,yaml,jinja,vim setlocal shiftwidth=2 tabstop=2 softtabstop=2
" }}}

if 0 | endif

call plug#begin()
" Plugins {{{
"
Plug 'maralla/mycolor'
Plug 'tpope/vim-fugitive' | Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive' | Plug 'gregsexton/gitv', {'on': 'Gitv'}

" color schemes
Plug 'altercation/vim-colors-solarized'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'

" web
Plug 'groenewege/vim-less', {'for': 'less'}
Plug 'cakebaker/scss-syntax.vim', {'for': ['scss','sass']}
Plug 'hail2u/vim-css3-syntax', {'for': ['css','scss','sass']}
Plug 'ap/vim-css-color', {'for': ['css','scss','sass','less','styl']}
Plug 'othree/html5.vim', {'for': ['html','jinja']}
Plug 'gregsexton/MatchTag', {'for': ['html','xml','jinja']}
Plug 'mattn/emmet-vim', {'for': ['html', 'jinja','xml','xsl','xslt','xsd','css','sass','scss', 'less','mustache']}
Plug 'pangloss/vim-javascript', {'for': 'javascript'}
Plug 'leshill/vim-json', {'for': 'json'}
Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}

" python
Plug 'hynek/vim-python-pep8-indent', {'for': 'python'}
Plug 'Glench/Vim-Jinja2-Syntax', {'for': ['jinja', 'html']}
Plug 'tshirtman/vim-cython', {'for': 'cython'}
Plug 'hdima/python-syntax', {'for': 'python'}
Plug 'maralla/rope.vim', {'for': 'python'}
Plug 'saltstack/salt-vim', {'for': 'sls'}

" rustlang
Plug 'rust-lang/rust.vim', {'for': 'rust'}
Plug 'cespare/vim-toml' | Plug 'maralla/vim-toml-enhance', {'for': 'toml'}

" c/c++
Plug 'justinmk/vim-syntax-extra', {'for': ['c', 'cpp', 'yacc', 'flex', 'lex']}

" scm
Plug 'mhinz/vim-signify'

" " autocomplete
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Valloric/YouCompleteMe', {'do': 'python install.py --clang-completer --gocode-completer --tern-completer --racer-completer'}

" editor
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-speeddating'
Plug 'thinca/vim-visualstar'
Plug 'tomtom/tcomment_vim'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
Plug 'chrisbra/NrrwRgn'
Plug 'godlygeek/tabular', {'on': 'Tabularize'}
Plug 'jiangmiao/auto-pairs'
Plug 'dhruvasagar/vim-table-mode', {'on': 'TableModeToggle'}

" navigation
Plug 'Lokaltog/vim-easymotion'
Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTreeFind']}
Plug 'majutsushi/tagbar'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimproc.vim', {'do': 'make'}
Plug 'Yggdroot/indentLine', {'on': 'IndentLinesToggle'}
Plug 'nathanaelkane/vim-indent-guides'

" misc
Plug 'junegunn/vim-pseudocl' | Plug 'junegunn/vim-oblique'
Plug 'gorkunov/smartpairs.vim'
Plug 'ksauzz/thrift.vim', {'for': 'thrift'}
Plug 'tpope/vim-scriptease', {'for': 'vim'}
Plug 'tpope/vim-markdown', {'for': 'markdown'}
Plug 'guns/xterm-color-table.vim', {'on': 'XtermColorTable'}
Plug 'maralla/vim-linter'
Plug 'mattn/webapi-vim' | Plug 'mattn/gist-vim', {'on': 'Gist'}

" }}}
call plug#end()

" settings {{{
set t_Co=256
set background=dark

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

" buffer
nnoremap <S-H> :bprev<CR>
nnoremap <S-L> :bnext<CR>

" tab
map <leader>tn :tabnew<CR>
map <leader>tc :tabclose<CR>
nnoremap <left> :tabprev<CR>
nnoremap <right> :tabnext<CR>
nnoremap <down> :tabprev<CR>
nnoremap <up> :tabnext<CR>

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

" make Y consistent with C and D. See :help Y.
nnoremap Y y$

" hide annoying quit message
nnoremap <C-c> <C-c>:echo<cr>

" quick buffer open
nnoremap gb :ls<cr>:e #

" general
nmap <leader>l :set list! list?<cr>

command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>

autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \  exe 'normal! g`"zvzz' |
  \ endif

"}}}

" Plugin Config {{{
"
" vim-airline
let g:airline_left_sep = '⮀'
let g:airline_left_alt_sep = '⮁'
let g:airline_right_sep = '⮂'
let g:airline_right_alt_sep = '⮃'
let g:airline_symbols = {}
let g:airline_symbols.space = ' '
let g:airline_symbols.linenr = "\u2b61"
let g:airline_symbols.branch = "\uf020"
let g:airline_symbols.readonly = '⭤'
let g:airline_section_b = '%{airline#util#wrap(airline#extensions#branch#get_head(),0)}'
let g:airline_section_c = '%t'
let g:airline_theme = 'myairline'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s '
let g:airline#extensions#tabline#buffer_min_count = 2
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#left_sep = '⮀'
let g:airline#extensions#tabline#left_alt_sep = '⮁'
let g:airline#extensions#tagbar#enabled = 1
if $TERM == 'screen' && $TMUX != ''
    let g:airline_section_z = airline#section#create_right(['%3p%% ⭡ %4l:%3c ', 'Tmux'])
endif

" altercation/vim-colors-solarized
let g:solarized_termcolors=256
colorscheme solarized

" scrooloose/nerdtree
let NERDTreeMinimalUI=1
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=0
let NERDTreeChDirMode=2
let NERDTreeShowBookmarks=1
let NERDTreeDirArrows = 1
let NERDTreeIgnore=['\.pyc', '__pycache__', 'egg-info', '\~$', '\.swo$',
            \'\.swp$', '\.git', '\.hg', '\.svn', '\.bzr', '\.DS_Store', '\.o',
            \'\.ropeproject', '\.cscope.files', '\.ycm_extra_conf.py']
let NERDTreeBookmarksFile='~/.vim/.cache/NERDTreeBookmarks'
nnoremap <C-N> :NERDTreeToggle<CR>
nnoremap <Leader>e :NERDTreeFind<CR>

" tpope/vim-unimpaired
nmap <c-up> [e
nmap <c-down> ]e
vmap <c-up> [egv
vmap <c-down> ]egv

" mattn/emmet-vim
function! s:zen_html_tab()
  let line = getline('.')
  if match(line, '<.*>') < 0
    return "\<c-y>,"
  endif
  return "\<c-y>n"
endfunction
autocmd FileType xml,xsl,xslt,xsd,css,sass,scss,less,mustache imap <buffer><c-o> <c-y>,
autocmd FileType html,jinja imap <buffer><expr><c-o> <sid>zen_html_tab()

" mhinz/vim-signify
let g:signify_update_on_bufenter=0

" tpope/vim-fugitive
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gb :Gblame<CR>
nnoremap <silent> <leader>gl :Glog<CR>
nnoremap <silent> <leader>gp :Git push<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gr :Gremove<CR>
autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>
autocmd BufReadPost fugitive://* set bufhidden=delete

" gregsexton/gitv
nnoremap <silent> <leader>gv :Gitv<CR>
nnoremap <silent> <leader>gV :Gitv!<CR>
let g:Gitv_DoNotMapCtrlKey = 1

" SirVer/ultisnips
let g:UltiSnipsExpandTrigger="<c-l>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetDirectories=[$HOME."/.vim/mysnippets"]
let g:UltiSnipsEditSplit = 'horizontal'
let g:UltiSnipsSnippetsDir=$HOME.'/.vim/mysnippets'

" Valloric/YouCompleteMe
let g:ycm_complete_in_comments_and_strings=1
let g:ycm_confirm_extra_conf = 0
let g:ycm_filetype_blacklist={'unite': 1}
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_path_to_python_interpreter = '/usr/bin/python'
let g:ycm_extra_conf_globlist = ["~/.ycm_extra_conf.py"]
nnoremap <leader>/ :YcmCompleter GoTo<CR>

" tomtom/tcomment_vim
let g:tcomment_types = {
            \ 'jinja': {'begin': '{# ', 'end': ' #}'},
            \ 'cython': {'begin': '# '}
            \ }

" terryma/vim-multiple-cursors
let g:multi_cursor_next_key='<c-x>'

" godlygeek/tabular
nmap <Leader>a& :Tabularize /&<CR>
vmap <Leader>a& :Tabularize /&<CR>
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:<CR>
vmap <Leader>a: :Tabularize /:<CR>
nmap <Leader>a:: :Tabularize /:\zs<CR>
vmap <Leader>a:: :Tabularize /:\zs<CR>
nmap <Leader>a, :Tabularize /,<CR>
vmap <Leader>a, :Tabularize /,<CR>
nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
vmap <Leader>a<Bar> :Tabularize /<Bar><CR>

" Lokaltog/vim-easymotion
hi link EasyMotionTarget WarningMsg
hi link EasyMotionShade Comment
let g:EasyMotion_do_mapping = 0
map f <Plug>(easymotion-f)
map F <Plug>(easymotion-F)
map b <Plug>(easymotion-b)
map B <Plug>(easymotion-B)

" Shougo/unite.vim
call unite#filters#matcher_default#use(['matcher_fuzzy', "matcher_hide_hidden_files"])
call unite#filters#sorter_default#use(['sorter_rank'])
call unite#custom#profile('files', 'context.smartcase', 1)
call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep,line,outline',
      \ 'ignore_pattern', join([
      \ '\.git/',
      \ 'git5/.*/review/',
      \ 'google/obj/',
      \ 'tmp/',
      \ '\.sass-cache',
      \ '\.hg/',
      \ '\.svn/',
      \ 'build/',
      \ '\.exe$',
      \ '\.so$',
      \ '\.dll$',
      \ '\.DS_Store/',
      \ '\.pyc$',
      \ '__pycache__/',
      \ 'undo/',
      \ 'node_modules/',
      \ 'bower_components/',
      \ '*\.min\.\(js\|css\)$',
      \ '\.egg-info',
      \ '\.tox',
      \ 'target'
      \ ], '\|'))
let g:unite_data_directory='~/.vim/.cache/unite'
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable=1
let g:unite_split_rule = 'topleft'
let g:unite_source_rec_max_cache_files=5000
let g:unite_prompt='» '

function! s:unite_settings()
  nmap <buffer> Q <plug>(unite_exit)
  nmap <buffer> <esc> <plug>(unite_exit)
  imap <buffer> <esc> <plug>(unite_exit)
  nmap <silent><buffer><expr> gs unite#do_action('vsplit')
  nmap <silent><buffer><expr> s unite#do_action('split')
endfunction
autocmd FileType unite call s:unite_settings()

nmap <space> [unite]
nnoremap [unite] <nop>
nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async:! buffer file_mru bookmark<cr><c-u>
nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async:!<cr><c-u>
nnoremap <silent> [unite]e :<C-u>Unite -buffer-name=recent file_mru<cr>
nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
nnoremap <silent> [unite]/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>
nnoremap <leader>nbu :Unite neobundle/update -vertical -no-start-insert<cr>

" Yggdroot/indentLine
let g:indentLine_char = '┆'
let g:indentLine_color_term = 239
let g:indentLine_fileTypeExclude = ['help']
let g:indentLine_noConcelCursor = 0
nnoremap <silent> <leader>il :IndentLinesToggle<CR>

" nathanaelkane/vim-indent-guides
let g:indent_guides_start_level=1
let g:indent_guides_guide_size=1
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_color_change_percent=3
if !has('gui_running')
  let g:indent_guides_auto_colors=0
  function! s:indent_set_console_colors()
    hi IndentGuidesOdd ctermbg=235
    hi IndentGuidesEven ctermbg=236
  endfunction
  autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
endif

" maralla/vim-linter
let g:airline_section_warning = airline#section#create(['linter'])
let g:linter_debug = 1

" mattn/gist-vim
let g:gist_post_private=1
let g:gist_show_privates=1

" hdima/python-syntax
let python_highlight_all = 1

" ropevim
let ropevim_vim_completion=1

" racer-rust/vim-racer
let $RUST_SRC_PATH = '/Users/maralla/Workspace/src/rust/src'
" }}}

" cscope {{{
let g:cscope_db_added = 0
function SetupCscope()
  if has("cscope")
      set cscopetag
      set csto=0
      if !g:cscope_db_added && filereadable(".cscope.out")
        let g:cscope_db_added = 1
        cs add .cscope.out
      endif
      set cscopeverbose


      """"""""""""" My cscope/vim key mappings
      "
      " The following maps all invoke one of the following cscope search types:
      "
      "   's'   symbol: find all references to the token under cursor
      "   'g'   global: find global definition(s) of the token under cursor
      "   'c'   calls:  find all calls to the function name under cursor
      "   't'   text:   find all instances of the text under cursor
      "   'e'   egrep:  egrep search for the word under cursor
      "   'f'   file:   open the filename under cursor
      "   'i'   includes: find files that include the filename under cursor
      "   'd'   called: find functions that function under cursor calls
      "
      nmap <leader>s :cs find s <C-R>=expand("<cword>")<CR><CR>
      nmap <leader>a :cs find g <C-R>=expand("<cword>")<CR><CR>
      nmap <leader>c :cs find c <C-R>=expand("<cword>")<CR><CR>
      nmap <leader>t :cs find t <C-R>=expand("<cword>")<CR><CR>
      nmap <leader>e :cs find e <C-R>=expand("<cword>")<CR><CR>
      nmap <leader>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
      nmap <leader>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
      nmap <leader>d :cs find d <C-R>=expand("<cword>")<CR><CR>

      command! -nargs=* G :cs find g <args>
  endif
endfunction

function CreateCscopeDB()
  if has("cscope")
    :silent !find . -iname '*.c' -o -iname '*.h' > .cscope.files
    :silent !cscope -b -i .cscope.files -f .cscope.out
    :silent :cs reset<CR>:cs add .cscope.out<CR>
    redraw!
  endif
endfunction

function UpdateCscopeDB()
  if filereadable(".cscope.out")
    call CreateCscopeDB()
  endif
endfunction

autocmd BufNewFile,BufRead *.c,*.h call SetupCscope()
autocmd BufNewFile,BufWrite *.c,*.h call UpdateCscopeDB()
nmap <leader><leader>s :call CreateCscopeDB()<CR>

"}}}

" misc {{{

" highlights
if g:colors_name == 'solarized'
  hi SignColumn ctermbg=235
endif

"}}}
