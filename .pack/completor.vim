let g:completor_subseq_binary = '/Users/maralla/Workspace/project/wordquery/target/release/wq'
let g:completor_disable_filename = 0
let g:completor_disable_buffer = 0
let g:completor_clang_binary = '/usr/bin/clang'
let g:completor_css_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
let g:completor_html_omni_trigger = '<?[a-z].*$'
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

" let g:completor_auto_trigger = 0
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-x>\<C-u>\<C-p>"

noremap <silent> <leader>d :call completor#do('definition')<CR>
" let g:completor_javascript_omni_trigger = "\\w+$|[\\w\\)\\]\\}\'\"]+\\.\\w*$"
let g:completor_set_options = 1
let g:completor_auto_close_doc = 1
let g:completor_completion_delay = 200
map <c-\> <Plug>CompletorCppJumpToPlaceholder
imap <c-\> <Plug>CompletorCppJumpToPlaceholder
