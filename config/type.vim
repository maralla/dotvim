" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

autocmd BufNewFile,BufRead *.json setfiletype json
autocmd BufNewFile,BufRead *.jinja setfiletype jinja
autocmd BufNewFile,BufRead *.pyx,*.pxi setfiletype cython
autocmd BufNewFile,BufRead *.sls setfiletype sls

autocmd FileType css,less,javascript,json,html,php,puppet,yaml,jinja,vim setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType js,json,scss,css autocmd BufWritePre <buffer> call StripTrailingWhitespace()
autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
autocmd FileType css,scss nnoremap <silent> <leader>S vi{:sort<CR>
autocmd FileType python setlocal cc=80
autocmd FileType markdown setlocal nolist
autocmd FileType vim setlocal keywordprg=:help
