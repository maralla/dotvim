let g:completor_subseq_binary = '/Users/maralla/Workspace/project/wordquery/target/release/wq'
let g:completor_disable_filename = 0
let g:completor_disable_buffer = 0
let g:completor_clang_binary = '/usr/bin/clang'
let g:completor_css_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
let g:completor_html_omni_trigger = '<?.*$'
let g:completor_php_omni_trigger = '([$\w]+|use\s*|->[$\w]*|::[$\w]*|implements\s*|extends\s*|class\s+[$\w]+|new\s*)$'
let g:completor_tex_omni_trigger = '\\\\(:?'
        \ .  '\w*cite\w*(?:\s*\[[^]]*\]){0,2}\s*{[^}]*'
        \ . '|\w*ref(?:\s*\{[^}]*|range\s*\{[^,}]*(?:}{)?)'
        \ . '|hyperref\s*\[[^]]*'
        \ . '|includegraphics\*?(?:\s*\[[^]]*\]){0,2}\s*\{[^}]*'
        \ . '|(?:include(?:only)?|input)\s*\{[^}]*'
        \ . '|\w*(gls|Gls|GLS)(pl)?\w*(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
        \ . '|includepdf(\s*\[[^]]*\])?\s*\{[^}]*'
        \ . '|includestandalone(\s*\[[^]]*\])?\s*\{[^}]*'
        \ .')$'
" let g:completor_cpp_omni_trigger = ''

let g:completor_auto_trigger = 1
" inoremap <expr> <c-n> pumvisible() ? "<C-N>" : "<C-R>=completor#do('complete')<CR>"

" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

noremap <silent> <leader>d :call completor#do('definition')<CR>
noremap <silent> <leader>r :call completor#do('references')<CR>
noremap <silent> <leader>,d :call completor#do('implementation')<CR>
noremap <silent> <leader>,r :call completor#do('symbol')<CR>
noremap <silent> <leader>c :call completor#do('doc')<CR>
noremap <silent> <leader>f :call completor#do('format')<CR>
noremap <silent> <leader>s :call completor#do('hover')<CR>
noremap <silent> <leader>z :call completor#do('code_action', "source.organizeImports")<CR>
noremap <silent> <leader>a :call completor#prompt#rename()<CR>
" let g:completor_javascript_omni_trigger = "\\w+$|[\\w\\)\\]\\}\'\"]+\\.\\w*$"
let g:completor_set_options = 1
let g:completor_use_popup_window = 1
let g:completor_auto_close_doc = 1
let g:completor_completion_delay = 200
let g:completor_go_guru_binary = 'guru'
let g:completor_go_gofmt_binary = 'goimports'
map <c-\> <Plug>CompletorCppJumpToPlaceholder
imap <c-\> <Plug>CompletorCppJumpToPlaceholder

let g:completor_filetype_map = {}
" let g:completor_filetype_map.javascript = {'ft': 'lsp', 'cmd': '/home/maralla/Workspace/tmp/node/node_modules/.bin/flow lsp'}
let g:completor_filetype_map.javascript = {'ft': 'lsp', 'cmd': '/home/maralla/Workspace/tmp/node/node_modules/.bin/typescript-language-server --stdio'}
" Enable lsp for go by using gopls
let g:completor_filetype_map.go = {'ft': 'lsp', 'cmd': 'gopls'}
" Enable lsp for rust by using rls
" let g:completor_filetype_map.rust = {'ft': 'lsp', 'cmd': 'rls'}
let g:completor_filetype_map.rust = {
      \   'ft': 'lsp',
      \   'cmd': 'rust-analyzer',
      \   'options': {
      \     'format': {
      \       'tabSize': 4,
      \       'insertSpaces': v:true
      \     }
      \   }
      \ }
" Enable lsp for c by using clangd
" let g:completor_filetype_map.c = {'ft': 'lsp', 'cmd': 'clangd-7'}
let g:completor_filetype_map.c = {'ft': 'lsp', 'cmd': '/usr/local/bin/ccls'}

let g:completor_filetype_map.json = {
      \ 'ft': 'lsp',
      \ 'cmd': '/home/maralla/Workspace/tmp/js/node_modules/.bin/vscode-json-languageserver --stdio',
      \ 'insertText': 'label',
      \ 'config': {
      \   'json': {
      \      'format': { 'enable': v:false },
      \      'schemas': [
      \        {'fileMatch': ['package.json'], 'url': 'http://json.schemastore.org/package'},
      \      ]
      \    }
      \  }
      \ }

let g:completor_filetype_map.dart = {
      \ 'ft': 'lsp',
      \ 'cmd': 'dart /home/maralla/Workspace/src/flutter/bin/cache/dart-sdk/bin/snapshots/analysis_server.dart.snapshot --lsp',
      \ }


let g:completor_black_binary = $HOME.'/Workspace/app/bin/isort_black'

" let g:completor_tsserver_binary = '/home/maralla/Workspace/tmp/node/node_modules/.bin/tsserver'

augroup completor_config
  autocmd!
  autocmd BufWritePost *.go,*.rs :call completor#do('format', #{after: ['code_action', 'source.organizeImports']})
augroup end
