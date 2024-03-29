let g:validator_filetype_map = {"python.django": "python", "javascript.jsx": "javascript", 'c': 'cpp'}
let g:validator_javascript_checkers = ['standard']
let g:validator_javascript_standard_binary = '/Users/maralla/Workspace/tmp/node_modules/.bin/standard'
let g:validator_vim_checkers = ['vint']
let g:validator_vim_vint_binary = '/Users/maralla/.dotfiles/virtualenvs/py36/bin/vint'
let g:validator_python_checkers = ['flake8']
let g:validator_auto_open_quickfix = 0
let g:validator_debug = 0
let g:validator_go_checkers = ['golangci-lint']
let g:validator_highlight_message = 1
" let g:validator_ignore = ['go']

let g:validator_use_popup_window = 1

hi ValidatorPopupColor guifg=#C51E1E ctermfg=160
hi ValidatorBorderColor guifg=#161616 ctermfg=233

let g:validator_debug=0

map <leader>e :call validator#next()<CR>
