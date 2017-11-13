" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

set encoding=utf-8
scriptencoding utf-8

" utils {{{
function! Preserve(command)
  " preparation: save last search, and cursor position.
  let _s=@/
  let l = line('.')
  let c = col('.')
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
" }}}

if 0 | endif

filetype plugin indent on
syntax enable

" settings {{{
" set t_Co=256
" set background=dark
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
colorscheme solarized8_dark

set timeoutlen=300                              " mapping timeout
set ttimeoutlen=50                              " keycode timeout
set mousehide                                   " hide when characters are typed
set history=1000                                " number of command lines to remember
set ttyfast                                     " assume fast terminal connection
set viewoptions=folds,options,cursor,unix,slash " unix/windows compatibility
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

set colorcolumn=80
set cursorline

" Autocmds.
augroup myvimrc
  autocmd BufNewFile,BufRead *.h setfiletype c
  autocmd FileType css,less,javascript,json,html,php,puppet,yaml,jinja,vim setlocal shiftwidth=2 tabstop=2 softtabstop=2
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \  exe 'normal! g`"zvzz' |
    \ endif
augroup END


if has('conceal')
  set conceallevel=1
  set listchars+=conceal:Δ
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

let mapleader = ','
let g:mapleader = ','

" mappings
vmap <leader>s :sort<cr>
nnoremap <leader>w :w<cr>
map <leader>pp :set paste!<CR>
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

"}}}

"netrw
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_list_hide= '__pycache__,.*\.pyc$,.*\.swp,\.git,\.ropeproject,\.cache,build,\.egg-info,dist'

" cscope {{{
let g:cscope_db_added = 0
function! SetupCscope()
  if has('cscope')
      set cscopetag
      set csto=0
      if !g:cscope_db_added && filereadable('.cscope.out')
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

function! CreateCscopeDB()
  if has('cscope')
    silent call system('find . -iname *.c -o -iname *.h -o -iname *.cpp > .cscope.files')
    silent call system('cscope -b -i .cscope.files -f .cscope.out')
    silent :cs reset
    redraw!
  endif
endfunction

function! UpdateCscopeDB()
  if filereadable('.cscope.out')
    call CreateCscopeDB()
  endif
endfunction

autocmd BufNewFile,BufRead *.c,*.h,*.cpp call SetupCscope()
autocmd BufNewFile,BufWritePost *.c,*.h,*.cpp call UpdateCscopeDB()
nmap <leader><leader>s :call CreateCscopeDB()<CR>
"}}}




" Status line
let s:min_status_width = 70
let s:mode_map = {
      \ 'n':      '  NORMAL ',
      \ 'no':     '  NO     ',
      \ 'v':      '  V-CHAR ',
      \ 'V':      '  V-LINE ',
      \ 'CTRL-V': '  V-BLOCK',
      \ 's':      '  S-CHAR ',
      \ 'S':      '  S-LINE ',
      \ 'CTRL-S': '  S-BLOCK',
      \ 'i':      '  INSERT ',
      \ 'ic':     '  I-COMP ',
      \ 'ix':     '  I-COMP ',
      \ 'R':      '  REPLACE',
      \ 'Rc':     '  R-COMP ',
      \ 'Rv':     '  R-VIRT ',
      \ 'Rx':     '  R-COMP ',
      \ 'c':      '  C-LINE ',
      \ 'cv':     '  EX     ',
      \ 'ce':     '  EX     ',
      \ 'r':      '  ENTER  ',
      \ 'rm':     '  MORE   ',
      \ 'r?':     '  CONFIRM',
      \ '!':      '  SHELL  ',
      \ }

function! StatusMode()
  if winwidth(0) <= s:min_status_width
    return ''
  endif
  let l:mode = mode()
  return has_key(s:mode_map, l:mode) ? s:mode_map[l:mode] : ''
endfunction

function! StatusPaste()
  if winwidth(0) <= s:min_status_width
    return ''
  endif
  return &paste ? ' PASTE ' : ''
endfunction

function! StatusBranch()
  if winwidth(0) <= s:min_status_width || !exists('*fugitive#head')
    return ''
  endif
  let branch = fugitive#head()
  return empty(branch) ? '' : "   \ue0a0 " . branch
endfunction

function! StatusFilename()
  let name = expand('%:t')
  let name = name !=# '' ? name : '[No Name]'
  if name =~? 'netrw'
    return 'netrw'
  endif
  let readonly = &readonly ? "\ue0a2 " : ''
  let modified = &modified ? ' +' : ''
  return '    '.readonly . name . modified
endfunction

function! StatusTag()
  if winwidth(0) <= s:min_status_width || !exists('*tagbar#currenttag')
    return ''
  endif
  let tag = tagbar#currenttag('%s', '', '')
  return empty(tag) ? '' : tag . '  '
endfunction

function! StatusFileType()
  if winwidth(0) <= s:min_status_width
    return ''
  endif
  return empty(&ft) ? '' : &ft . '   '
endfunction

function! StatusLineInfo()
  if winwidth(0) <= s:min_status_width
    return ''
  endif
  let msg = printf('%-4d:%-3d', line('.'), col('.'))
  return " \ue0a1 " . msg
endfunction

function! StatusTmux()
  if winwidth(0) <= s:min_status_width
    return ''
  endif
  return $TERM ==? 'screen' && $TMUX !=? '' ? '   @tmux   ' : ''
endfunction

function! StatusValidator()
  if winwidth(0) <= s:min_status_width
    return ''
  endif
  return validator#get_status_string()
endfunction


function! s:create_statusline(mode)
  hi StatusLine            guifg=#212121
  hi StatusLineNC          guifg=#212121
  hi StatusActiveMode      guifg=#757575 guibg=#212121
  hi StatusActivePaste     guifg=#757575 guibg=#212121
  hi StatusActiveBranch    guifg=#757575 guibg=#212121
  hi StatusActiveFName     guifg=#757575 guibg=#212121
  hi StatusActiveTag       guifg=#757575 guibg=#212121
  hi StatusActiveFType     guifg=#757575 guibg=#212121
  hi StatusActiveLInfo     guifg=#757575 guibg=#212121
  hi StatusActiveTmux      guifg=#757575 guibg=#212121
  hi StatusActiveValidator guifg=#C62828 guibg=#212121

  let parts = [
        \ '%#Status' .a:mode. 'Mode#%{StatusMode()}',
        \ '%#Status' .a:mode. 'Paste#%{StatusPaste()}',
        \ '%#Status' .a:mode. 'Branch#%-{StatusBranch()}',
        \ '%#Status' .a:mode. 'FName#%{StatusFilename()}',
        \ '%=',
        \ '%#Status' .a:mode. 'Tag#%{StatusTag()}',
        \ '%#Status' .a:mode. 'FType#%{StatusFileType()}',
        \ '%#Status' .a:mode. 'LInfo#%{StatusLineInfo()}',
        \ '%#Status' .a:mode. 'Tmux#%{StatusTmux()}',
        \ '%#Status' .a:mode. 'Validator#%{StatusValidator()}'
        \ ]
  exe 'setlocal statusline=' . join(parts, '')
endfunction

augroup mystatusline
  autocmd WinEnter,BufWinEnter * call s:create_statusline('Active')
  autocmd WinLeave * call s:create_statusline('Inactive')
augroup END
