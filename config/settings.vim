" airline
let airline = neobundle#get("vim-airline")
function! airline.hooks.on_source(airline)
  if $TERM == 'screen' && $TMUX != ''
    function! AirlineSetup()
      let g:airline_section_z = airline#section#create_right(['%3p%% ⭡ %4l:%3c ', 'Tmux'])
    endfunction
    autocmd VimEnter * call AirlineSetup()
  endif
endfunction
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


" maksimr/vim-jsbeautify
nnoremap <leader>fjs :call JsBeautify()<cr>


" phildawes/racer
let g:racer_cmd = '~/.vim/bundle/racer/target/release/racer'
let $RUST_SRC_PATH = '/Users/maralla/Workspace/src/rust/src'


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
let g:UltiSnipsSnippetsDir='~/.vim/mysnippets'
let g:UltiSnipsSnippetDirectories=["mysnippets"]
let g:UltiSnipsEditSplit = 'horizontal'


" Valloric/YouCompleteMe
if g:complete_method == 'ycm'
  let g:ycm_complete_in_comments_and_strings=1
  let g:ycm_filetype_blacklist={'unite': 1}
  let g:ycm_autoclose_preview_window_after_completion = 1
  let g:ycm_path_to_python_interpreter = '/usr/bin/python'
  let g:ycm_extra_conf_globlist = ["~/.ycm_extra_conf.py"]
  nnoremap <leader>/ :YcmCompleter GoTo<CR>
elseif g:complete_method == 'neocomplete'
  let g:neocomplete#enable_at_startup=1
  let g:neocomplete#data_directory='~/.vim/.cache/neocomplete'
elseif g:complete_method == 'neocomplcache'
  let g:neocomplcache_enable_at_startup=1
  let g:neocomplcache_temporary_dir='~/.vim/.cache/neocomplcache'
  let g:neocomplcache_enable_fuzzy_completion=1
endif


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


" justinmk/vim-sneak
let g:sneak#streak = 1


" Lokaltog/vim-easymotion
hi link EasyMotionTarget WarningMsg
hi link EasyMotionShade Comment
let g:EasyMotion_do_mapping = 0
map f <Plug>(easymotion-f)
map F <Plug>(easymotion-F)
map b <Plug>(easymotion-b)
map B <Plug>(easymotion-B)


" mileszs/ack.vim
if executable('ag')
  let g:ackprg = "ag --nogroup --column --smart-case --follow"
endif


" mbbill/undotree
let g:undotree_SplitLocation='botright'
let g:undotree_SetFocusWhenToggle=1
nnoremap <silent> <F5> :UndotreeToggle<CR>


" EasyGrep
let g:EasyGrepRecursive=1
let g:EasyGrepAllOptionsInExplorer=1
let g:EasyGrepCommand=1
nnoremap <leader>vo :GrepOptions<cr>


" Shougo/vimfiler.vim
let g:vimfiler_no_default_key_mappings = 1
function! s:vimfiler_settings()
  nmap <buffer> j <Plug>(vimfiler_loop_cursor_down)
  nmap <buffer> k <Plug>(vimfiler_loop_cursor_up)
  " nmap <buffer> h <Plug>(vimfiler_smart_h)
  " nmap <buffer> l <Plug>(vimfiler_smart_l)
  nmap <buffer> o <Plug>(vimfiler_expand_tree)
endfunction
autocmd FileType vimfiler call s:vimfiler_settings()


" scrooloose/nerdtree
let NERDTreeMinimalUI=1
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=0
let NERDTreeChDirMode=2
let NERDTreeShowBookmarks=1
let NERDTreeDirArrows = 1
let NERDTreeIgnore=['\.pyc', '__pycache__', 'egg-info', '\~$', '\.swo$',
            \'\.swp$', '\.git', '\.hg', '\.svn', '\.bzr', '\.DS_Store']
let NERDTreeBookmarksFile='~/.vim/.cache/NERDTreeBookmarks'
nnoremap <C-N> :NERDTreeToggle<CR>
nnoremap <Leader>e :NERDTreeFind<CR>


" Shougo/unite.vim
let bundle = neobundle#get('unite.vim')
function! bundle.hooks.on_source(bundle)
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
        \ '*\.min\.\(js\|css\)$',
        \ '\.egg-info',
        \ '\.tox',
        \ 'target'
        \ ], '\|'))
endfunction

let g:unite_data_directory='~/.vim/.cache/unite'
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable=1
let g:unite_split_rule = 'topleft'
let g:unite_source_rec_max_cache_files=5000
let g:unite_prompt='» '

if executable('ag')
  let g:unite_source_grep_command='ag'
  let g:unite_source_grep_default_opts='--nocolor --nogroup -S -C4'
  let g:unite_source_grep_recursive_opt=''
elseif executable('ack')
  let g:unite_source_grep_command='ack'
  let g:unite_source_grep_default_opts='--no-heading --no-color -a -C4'
  let g:unite_source_grep_recursive_opt=''
endif

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


" osyo-manga/unite-airline_themes
nnoremap <silent> [unite]a :<C-u>Unite -winheight=10 -auto-preview -buffer-name=airline_themes airline_themes<cr>


" ujihisa/unite-colorscheme
nnoremap <silent> [unite]c :<C-u>Unite -winheight=10 -auto-preview -buffer-name=colorschemes colorscheme<cr>


" tsukkee/unite-tag
nnoremap <silent> [unite]t :<C-u>Unite -auto-resize -buffer-name=tag tag tag/file<cr>


" Shougo/unite-outline
nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>


" Shougo/unite-help
nnoremap <silent> [unite]h :<C-u>Unite -auto-resize -buffer-name=help help<cr>


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


" maralla/vim-fixup
let fixup = neobundle#get("vim-fixup")
function! fixup.hooks.on_source(fixup)
  function s:fixup_setup()
    let g:airline_section_warning = airline#section#create(['fixup'])
  endfunction
  autocmd VimEnter * call s:fixup_setup()
endfunction


" mattn/gist-vim
let g:gist_post_private=1
let g:gist_show_privates=1


" altercation/vim-colors-solarized
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1
