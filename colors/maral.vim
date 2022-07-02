set background=dark
hi clear
if exists("syntax_on")
        syntax reset
endif

let g:colors_name = "maral"

" hi Normal       guibg=#161616 guifg=#81848A
" hi Normal       guibg=NONE guifg=#81848A
hi Normal       guibg=NONE guifg=NONE                ctermbg=NONE ctermfg=NONE
hi ColorColumn  guibg=#0B0B0B                        ctermbg=233
hi CursorLine   guibg=#0B0B0B                        ctermbg=NONE ctermfg=NONE cterm=NONE term=NONE
hi VertSplit    guibg=#0B0B0B guifg=#414141 gui=NONE ctermbg=233 ctermfg=238 term=NONE cterm=NONE
hi Signcolumn   guibg=#0B0B0B guifg=NONE             ctermbg=233 ctermfg=NONE
hi FoldColumn   guibg=#0B0B0B guifg=#2b2b2b          ctermbg=233 ctermfg=235
hi SpecialKey   guibg=#0B0B0B guifg=#212a2d          ctermbg=233 ctermfg=235

hi Constant     guifg=#82976F                     ctermfg=108
hi Folded       guifg=#616161 guibg=NONE          ctermfg=59 ctermbg=NONE
hi Statement    guifg=#5E81AC                     ctermfg=67
hi Search       guibg=#292E38 guifg=NONE gui=NONE ctermbg=235 ctermfg=NONE term=NONE cterm=bold
hi IncSearch    guibg=#292E38 guifg=NONE gui=NONE ctermbg=235 ctermfg=NONE term=NONE cterm=bold
hi Visual       guibg=#292E38 guifg=NONE gui=NONE ctermbg=235 ctermfg=NONE term=NONE cterm=NONE
hi Identifier   guifg=#81A1C1                     ctermfg=110 cterm=NONE
hi PreProc      guifg=#9E7D98                     ctermfg=139
hi Special      guifg=#B37460                     ctermfg=131

hi Comment      guifg=#62697B gui=italic          ctermfg=238 ctermbg=NONE cterm=italic
hi MatchParen   guifg=#fdf6e3 guibg=NONE gui=bold ctermfg=230 ctermbg=NONE
hi LineNr       guibg=#212121                     ctermbg=234
hi CursorLineNr guibg=#212121 guifg=#839496       ctermbg=234 ctermfg=245
hi DiffAdd      guibg=#212121                     ctermbg=234
hi DiffChange   guibg=#212121                     ctermbg=234
hi DiffDelete   guibg=#212121                     ctermbg=234
hi DiffText     guibg=#902330                     ctermbg=88
hi Type         guifg=#A38D61                     ctermfg=137
hi Pmenu        guifg=#696C70 guibg=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE 
hi PmenuSel     guibg=#232323 guifg=NONE gui=NONE ctermbg=235 ctermfg=NONE cterm=NONE 
hi PmenuSbar    guibg=#343638 guifg=NONE gui=NONE ctermbg=236 ctermfg=NONE cterm=NONE 
hi PmenuThumb   guibg=#515457 guifg=NONE gui=NONE ctermbg=239 ctermfg=NONE cterm=NONE 
hi NonText      guifg=#464646 guibg=NONE          ctermfg=238 ctermbg=NONE
hi ToDo         guifg=#892020 guibg=NONE gui=bold ctermfg=88  ctermbg=NONE cterm=bold

hi rustCommentLineDoc guifg=#714E41 ctermfg=95
