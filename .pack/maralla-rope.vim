let g:ropevim_enable_shortcuts = 0
let g:ropevim_guess_project = 1

autocmd FileType python map gd :call RopeGotoDefinition()<CR>
