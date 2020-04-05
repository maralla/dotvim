" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

set encoding=utf-8
scriptencoding utf-8

" utils {{{
func! Preserve(command)
  " preparation: save last search, and cursor position.
  let _s=@/
  let l = line('.')
  let c = col('.')
  " do the business:
  execute a:command
  " clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunc

func! StripTrailingWhitespace()
  call Preserve("%s/\\s\\+$//e")
endfunc

func! EnsureExists(path)
  if !isdirectory(expand(a:path))
    call mkdir(expand(a:path))
  endif
endfunc
" }}}

if 0 | endif

" settings {{{
filetype plugin indent on
syntax enable

" set t_Co=256
" set background=dark
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
"colorscheme solarized8

set timeoutlen=300                              " mapping timeout
set ttimeoutlen=50                              " keycode timeout
set mousehide                                   " hide when characters are typed
set history=1000                                " number of command lines to remember
set ttyfast                                     " assume fast terminal connection
set viewoptions=folds,options,cursor,unix,slash " unix/windows compatibility
" sync with OS clipboard
if has('linux')
  set clipboard=unnamedplus
else
  set clipboard=unnamed
endif
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
set fillchars=vert:│,fold:\ 
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
" set number
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
set signcolumn=yes

packadd matchit

func! s:set_snippets_type()
  if &ft ==? 'neosnippet'
    setlocal ft=snippets
  endif
endfunc

func! s:delay_set(fn)
  call timer_start(16, a:fn)
endfunc

" Autocmds.
augroup myvimrc
  autocmd!
  autocmd BufNewFile,BufRead *.snippets call s:delay_set({->s:set_snippets_type()})
  autocmd BufNewFile,BufRead *.h set filetype=c
  autocmd BufReadPost * try | exe 'normal! g`"' | catch /E19/ | endtry
  autocmd FileType css,less,javascript,json,html,puppet,yaml,jinja,vim,vue setlocal shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType go setlocal noexpandtab nowrap
  autocmd WinEnter,BufWinEnter * if &ft != '__margin__' | set cursorline | endif
  autocmd WinLeave * if &ft != '__margin__' | set nocursorline | endif
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

" Cursor shape config.
if exists('$TMUX')
  if has('linux')
    let &t_SI = "\<ESC>[6 q"
    let &t_EI = "\<ESC>[0 q"
  else
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
  endif
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
" }}}


" mappings {{{
let mapleader = ','
let g:mapleader = ','

vmap <leader>s :sort<cr>
nnoremap <leader>w :w<cr>
map <leader>pp :set paste!<CR>
nmap <silent> <leader>,/ :nohlsearch<CR>
cmap w!! w !sudo tee % >/dev/null

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <silent> j gj
nnoremap <silent> k gk

nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *N
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz

vnoremap < <gv
vnoremap > >gv

" reselect last paste
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" make Y consistent with C and D. See :help Y.
nnoremap Y y$

" hide annoying quit message
nnoremap <C-c> <C-c>:echo<cr>

" quick buffer open
nnoremap gb :ls<cr>:e #

" general
nmap <leader>l :set list! list?<cr>

" insert empty line
nmap <leader><space> m`o<ESC>``

func! s:get_selected()
  try
    let bak = @a
    silent! normal! gv"ay
    return @a
  finally
    let @a = bak
  endtry
endfunc
vnoremap * <ESC>:call setreg("/", <SID>get_selected())<CR>nN

" file finder
nnoremap <space>f :call filefinder#create_prompt()<CR>
"}}}

augroup hunkstart
  autocmd!
  autocmd VimEnter * call hunk#start()
augroup END

"netrw
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_list_hide= '__pycache__,.*\.pyc$,.*\.swp,\.git,\.ropeproject,\.cache,build/,\.egg-info,dist,\.DS_Store'

" cscope {{{
let g:cscope_db_added = 0
func! SetupCscope()
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
endfunc

func! CreateCscopeDB()
  if has('cscope')
    silent call system("find . -iname '*.c' -o -iname '*.h' -o -iname '*.cpp' > .cscope.files")
    silent call system('cscope -b -i .cscope.files -f .cscope.out')
    silent :cs reset
    redraw!
  endif
endfunc

func! UpdateCscopeDB()
  if filereadable('.cscope.out')
    call CreateCscopeDB()
  endif
endfunc

" autocmd BufNewFile,BufRead *.c,*.h,*.cpp call SetupCscope()
" autocmd BufNewFile,BufWritePost *.c,*.h,*.cpp call UpdateCscopeDB()
" nmap <leader><leader>s :call CreateCscopeDB()<CR>
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

func! s:status_ignore()
  return winwidth(0) <= s:min_status_width || &ft ==# 'netrw'
endfunc

func! StatusMode()
  if s:status_ignore() || &readonly
    return ''
  endif
  let l:mode = mode()
  return has_key(s:mode_map, l:mode) ? s:mode_map[l:mode] : ''
endfunc

func! StatusPaste()
  if s:status_ignore()
    return ''
  endif
  return &paste ? ' PASTE ' : ''
endfunc

func! StatusBranch()
  if s:status_ignore() || !exists('*fugitive#head')
    return ''
  endif
  let branch = fugitive#head()
  return empty(branch) ? '' : "   \uF020 " . branch
endfunc

func! StatusFilename()
  let name = expand('%:t')
  let name = name !=# '' ? "\uf022 " . name : '[No Name]'
  if &ft ==# 'netrw'
    let name = '  netrw'
  endif
  call s:hi_filename()
  let ignore = s:status_ignore()
  let empty = ignore ? '  ' : '    '
  return empty . name
endfunc

func! StatusTag()
  if s:status_ignore() || !exists('*tagbar#currenttag')
    return ''
  endif
  let tag = tagbar#currenttag('%s', '', '')
  return empty(tag) ? '' : tag . '  '
endfunc

func! StatusFileType()
  if s:status_ignore() || get(b:, 'statusline_hide_filetype', v:true)
    return ''
  endif
  return empty(&ft) ? '' : &ft . '   '
endfunc

func! StatusLineInfo()
  if s:status_ignore()
    return ''
  endif
  let msg = printf('%d:%d', line('.'), col('.'))
  return " \u2b61 " . msg . '  '
endfunc

func! StatusTmux()
  if s:status_ignore()
    return ''
  endif
  return $TMUX !=? '' ? '   @tmux   ' : ''
endfunc

func! StatusValidator()
  if s:status_ignore() || !exists('*validator#get_status_string')
    return ''
  endif
  return validator#get_status_string()
endfunc


func! s:hi(item, bg, ...)
  let fg = ''
  let extra = ''
  if a:0 >= 2
    let fg = a:1
    let extra = a:2
  elseif a:0 > 0
    let fg = a:1
  endif
  let guifg = empty(fg) ? '' : ' guifg=' . fg
  let extra = empty(extra) ? '' : ' ' . extra
  exe 'hi ' . a:item . guifg . ' guibg=' . a:bg . extra
endfunc


let s:color = {
      \ 'status_bg': '#212121',
      \ 'status_fg': '#757575',
      \ 'status_nc_bg': '#212121',
      \ 'status_nc_fg': '#6b6b6b',
      \ 'fname_modified': '#c38300',
      \ 'fname_readonly': '#525252',
      \ }
" if exists('$TMUX')
"   let s:color = {
"         \ 'status_bg': '#212121',
"         \ 'status_fg': '#757575',
"         \ 'fname_modified': '#c38300',
"         \ 'fname_readonly': '#525252',
"         \ }
" endif

func! s:hi_filename()
  if &modified
    call s:hi('StatusActiveFName', s:color.status_bg, s:color.fname_modified)
    call s:hi('StatusInactiveFName', s:color.status_bg, s:color.fname_modified)
  elseif &readonly
    call s:hi('StatusActiveFName', s:color.status_bg, s:color.fname_readonly)
    call s:hi('StatusInactiveFName', s:color.status_bg, s:color.fname_readonly)
  else
    hi clear StatusActiveFName
    hi clear StatusInactiveFName
    hi link StatusActiveFName       StatusActiveMode
    hi link StatusInactiveFName     StatusActiveMode
  endif
endfunc


let s:status_ignored_types = ['unite', 'finder', '__margin__']


func! s:set_highlight()
  call s:hi('StatusLine', s:color.status_bg, s:color.status_bg, 'term=NONE gui=NONE cterm=NONE')
  call s:hi('StatusLineNC', s:color.status_nc_bg, s:color.status_nc_bg, 'term=NONE gui=NONE cterm=NONE')

  if index(s:status_ignored_types, &ft) >= 0
    return
  endif

  call s:hi('StatusActiveMode', s:color.status_bg, s:color.status_fg)
  hi link StatusActivePaste     StatusActiveMode
  hi link StatusActiveBranch    StatusActiveMode
  hi link StatusActiveTag       StatusActiveMode
  hi link StatusActiveFType     StatusActiveMode
  hi link StatusActiveLInfo     StatusActiveMode
  hi link StatusActiveTmux      StatusActiveMode

  call s:hi_filename()
  call s:hi('StatusActiveValidator', s:color.status_bg, '#C62828')

  call s:hi('VertSplit', s:color.status_bg, s:color.status_fg)
  call s:hi('SignColumn', s:color.status_bg)
  call s:hi('ValidatorErrorSign', s:color.status_bg, '#C62828', 'cterm=bold')
  call s:hi('ValidatorWarningSign', s:color.status_bg, '#F9A825', 'cterm=bold')
endfunc
call s:set_highlight()


func! StatusSpace()
  return &ft ==# 'netrw' ? '' : '  '
endfunc


func! s:create_statusline(mode)
  if index(s:status_ignored_types, &ft) >= 0
    return
  endif

  if a:mode ==? 'active'
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
  else
    let parts = ['%{StatusSpace()}', '%#Status' .a:mode. 'FName#%{StatusFilename()}']
  endif
  exe 'setlocal statusline=' . join(parts, '')
endfunc

augroup mystatusline "{{{
  autocmd WinEnter,BufWinEnter * call s:create_statusline('Active')
  autocmd WinLeave * call s:create_statusline('Inactive')
augroup END "}}}


" ********************************
" colorscheme
hi Constant     guifg=#82976F
hi Folded       guifg=#616161 guibg=NONE
hi Statement    guifg=#5E81AC
hi Search       guibg=#292E38 term=NONE cterm=bold gui=NONE guifg=NONE
hi IncSearch    guibg=#292E38 term=NONE cterm=bold gui=NONE guifg=NONE
hi Visual       guibg=#292E38 term=NONE cterm=NONE gui=NONE guifg=NONE
hi Identifier   guifg=#81A1C1
hi PreProc      guifg=#9E7D98
hi Special      guifg=#B37460
hi SpecialKey   guifg=#212a2d guibg=#191919
hi Normal       guibg=#161616 guifg=#81848A
hi Comment      guifg=#41495A gui=italic ctermfg=NONE ctermbg=NONE cterm=italic
hi CursorLine   guibg=#191919 cterm=NONE
hi ColorColumn  guibg=#191919
hi MatchParen   gui=bold      guifg=#fdf6e3 guibg=NONE
hi LineNr       guibg=#212121
hi CursorLineNr guibg=#212121 guifg=#839496
hi DiffAdd      guibg=#212121
hi DiffChange   guibg=#212121
hi DiffDelete   guibg=#212121
hi Type         guifg=#A38D61
hi VertSplit    guibg=#414141 guifg=#212121
hi Pmenu        cterm=NONE gui=NONE guibg=#252525 guifg=#696C70
hi PmenuSel     cterm=NONE gui=NONE guibg=#343638 guifg=NONE
hi PmenuSbar    cterm=NONE gui=NONE guibg=#343638 guifg=NONE
hi PmenuThumb   cterm=NONE gui=NONE guibg=#515457 guifg=NONE
hi NonText      guifg=#464646 guibg=NONE
hi ToDo         guifg=#892020 guibg=NONE gui=bold cterm=bold

hi rustCommentLineDoc guifg=#714E41
" ********************************


" ********************************
" abbreviate
ab todo TODO
" ********************************
