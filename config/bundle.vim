" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

NeoBundle 'Shougo/vimproc.vim', {
  \ 'build': {
    \ 'mac': 'make -f make_mac.mak',
    \ 'unix': 'make -f make_unix.mak',
    \ 'cygwin': 'make -f make_cygwin.mak',
    \ 'windows': '"C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\nmake.exe" make_msvc32.mak',
  \ },
\ }

NeoBundle 'maralla/mycolor'
NeoBundle 'bling/vim-airline'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-dispatch'
NeoBundle 'tpope/vim-eunuch'
NeoBundle 'tpope/vim-unimpaired'


" web
NeoBundleLazy 'groenewege/vim-less', {'autoload':{'filetypes':['less']}}
NeoBundleLazy 'cakebaker/scss-syntax.vim', {'autoload':{'filetypes':['scss','sass']}}
NeoBundleLazy 'hail2u/vim-css3-syntax', {'autoload':{'filetypes':['css','scss','sass']}}
NeoBundleLazy 'ap/vim-css-color', {'autoload':{'filetypes':['css','scss','sass','less','styl']}}
NeoBundleLazy 'othree/html5.vim', {'autoload':{'filetypes':['html','jinja']}}
NeoBundleLazy 'gregsexton/MatchTag', {'autoload':{'filetypes':['html','xml','jinja']}}
NeoBundleLazy 'mattn/emmet-vim', {
      \ 'autoload': {
      \   'filetypes': [
      \     'html', 'jinja','xml','xsl','xslt','xsd','css','sass','scss',
      \     'less','mustache'
      \    ]
      \  }
      \ }

NeoBundleLazy 'marijnh/tern_for_vim', {
      \ 'autoload': {'filetypes': ['javascript']},
      \ 'build': {
      \   'mac': 'npm install',
      \   'unix': 'npm install',
      \   'cygwin': 'npm install',
      \   'windows': 'npm install',
      \ },
      \ }

NeoBundleLazy 'pangloss/vim-javascript', {'autoload':{'filetypes':['javascript']}}
NeoBundleLazy 'leshill/vim-json', {'autoload':{'filetypes':['json']}}
NeoBundleLazy 'maksimr/vim-jsbeautify', {'autoload':{'filetypes':['javascript']}}
NeoBundleLazy 'kchmck/vim-coffee-script', {'autoload': {'filetypes':['coffee']}}


" python
NeoBundleLazy 'hynek/vim-python-pep8-indent', {'autoload': {'filetypes': ['python']}}
NeoBundleLazy 'Glench/Vim-Jinja2-Syntax', {'autoload': {'filetypes': ['jinja', 'html']}}
NeoBundleLazy 'tshirtman/vim-cython', {'autoload': {'filetypes': ['cython']}}


" golang
NeoBundleLazy 'jnwhiteh/vim-golang', {'autoload': {'filetypes': ['go']}}
NeoBundleLazy 'maralla/vim-gocode', {
      \ 'autoload': {'filetypes': ['go']},
      \ 'build': {'mac': 'make', 'unix': 'make'}
      \ }


" rustlang
NeoBundle 'rust-lang/rust.vim'
NeoBundleLazy 'phildawes/racer', {
      \ 'autoload': {'filetypes': ['rust']},
      \ 'build' : {
      \   'mac': 'cargo build --release',
      \     'unix': 'cargo build --release',
      \   }
      \ }
NeoBundle 'maralla/vim-toml-enhance', {'depends': 'cespare/vim-toml'}

" c/c++
NeoBundleLazy 'justinmk/vim-syntax-extra', {'autoload': {'filetypes': ['c', 'cpp']}}


" scm
NeoBundle 'mhinz/vim-signify'
if executable('hg')
  NeoBundle 'bitbucket:ludovicchabant/vim-lawrencium'
endif
NeoBundle 'tpope/vim-fugitive'
NeoBundleLazy 'gregsexton/gitv', {'depends':['tpope/vim-fugitive'], 'autoload':{'commands':'Gitv'}}


" autocomplete
NeoBundle 'honza/vim-snippets'
NeoBundle 'SirVer/ultisnips'

if filereadable(expand("~/.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core.*"))
  let g:complete_method = 'ycm'
else
  let g:complete_method = 'neocomplete'
endif

if g:complete_method == 'ycm'
  NeoBundle 'Valloric/YouCompleteMe', {'vim_version':'7.3.584'}
elseif g:complete_method == 'neocomplete'
  NeoBundleLazy 'Shougo/neocomplete.vim', {'autoload':{'insert':1}, 'vim_version':'7.3.885'}
elseif g:complete_method == 'neocomplcache'
  NeoBundleLazy 'Shougo/neocomplcache.vim', {'autoload':{'insert':1}}
endif


" editor
NeoBundleLazy 'editorconfig/editorconfig-vim', {'autoload':{'insert':1}}
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-speeddating'
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'terryma/vim-expand-region'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'chrisbra/NrrwRgn'
NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}}
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'justinmk/vim-sneak'


" navigation
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'mileszs/ack.vim'
NeoBundleLazy 'mbbill/undotree', {'autoload':{'commands':'UndotreeToggle'}}
NeoBundleLazy 'EasyGrep', {'autoload':{'commands':'GrepOptions'}}
NeoBundle 'Shougo/vimfiler.vim'
NeoBundleLazy 'scrooloose/nerdtree', {'autoload':{'commands':['NERDTreeToggle','NERDTreeFind']}}

" NeoBundleLazy 'majutsushi/tagbar', {'autoload':{'commands':'TagbarToggle'}}
" nnoremap <silent> <leader>t :TagbarToggle<CR>

NeoBundle 'Shougo/unite.vim'
NeoBundleLazy 'Shougo/neomru.vim', {'autoload':{'unite_sources':'file_mru'}}
NeoBundleLazy 'osyo-manga/unite-airline_themes', {'autoload':{'unite_sources':'airline_themes'}}
NeoBundleLazy 'ujihisa/unite-colorscheme', {'autoload':{'unite_sources':'colorscheme'}}
NeoBundleLazy 'tsukkee/unite-tag', {'autoload':{'unite_sources':['tag','tag/file']}}
NeoBundleLazy 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}}
NeoBundleLazy 'Shougo/unite-help', {'autoload':{'unite_sources':'help'}}
NeoBundleLazy 'Yggdroot/indentLine', {'autoload': {'commands': 'IndentLinesToggle'}}
NeoBundle 'nathanaelkane/vim-indent-guides'


" misc
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-indent'
NeoBundle 'kana/vim-textobj-entire'
NeoBundle 'junegunn/vim-pseudocl'
NeoBundle 'junegunn/vim-oblique'
NeoBundle 'gorkunov/smartpairs.vim'
NeoBundle 'lucapette/vim-textobj-underscore'
NeoBundleLazy 'saltstack/salt-vim', {'autoload': {'filetypes': ['sls']}}

if exists('$TMUX')
  NeoBundle 'christoomey/vim-tmux-navigator'
endif

NeoBundleLazy 'ksauzz/thrift.vim', {'autoload': {'filetypes': ['thrift']}}
NeoBundleLazy 'tpope/vim-scriptease', {'autoload':{'filetypes':['vim']}}
NeoBundleLazy 'tpope/vim-markdown', {'autoload':{'filetypes':['markdown']}}

if executable('redcarpet') && executable('instant-markdown-d')
  NeoBundleLazy 'suan/vim-instant-markdown', {'autoload':{'filetypes':['markdown']}}
endif

NeoBundleLazy 'guns/xterm-color-table.vim', {'autoload':{'commands':'XtermColorTable'}}
NeoBundle 'chrisbra/vim_faq'
NeoBundle 'vimwiki'
NeoBundle 'bufkill.vim'
NeoBundle 'maralla/vim-fixup'
NeoBundleLazy 'mattn/gist-vim', { 'depends': 'mattn/webapi-vim', 'autoload': { 'commands': 'Gist' } }
NeoBundle 'ryanss/vim-hackernews'


" color schemes
NeoBundle 'altercation/vim-colors-solarized'
