let g:unite_data_directory='~/.vim/.cache/unite'
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable=1
let g:unite_split_rule = 'topleft'
let g:unite_source_rec_max_cache_files=5000
let g:unite_prompt='» '
let g:unite_force_overwrite_statusline = 0

let g:unite_source_grep_command = 'rg'
let g:unite_source_grep_default_opts = '--vimgrep --no-ignore-vcs'

nmap <space> [unite]
nnoremap [unite] <nop>
nnoremap <silent> [unite]f :Unite -toggle -auto-resize -buffer-name=files file_rec/async:!<CR>
nnoremap <silent> [unite]/ :Unite -no-quit -buffer-name=search grep:.<CR>
" nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async:! buffer file_mru bookmark<cr><c-u>
" nnoremap <silent> [unite]e :<C-u>Unite -buffer-name=recent file_mru<cr>
" nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
" nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
" nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
" nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
" nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>

call unite#filters#matcher_default#use(['matcher_fuzzy', 'matcher_hide_hidden_files'])
call unite#filters#matcher_default#use(['matcher_fuzzy', 'matcher_hide_hidden_files'])
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
      \ 'bower_components/',
      \ '*\.min\.\(js\|css\)$',
      \ '\.egg-info',
      \ '\.tox',
      \ 'target',
      \ 'dist',
      \ '\.venv',
      \ '\.cache',
      \ '\.ropeproject'
      \ ], '\|'))


function! UniteStatusLen()
  if !exists('b:unite')
    return ''
  endif
  return b:unite.candidates_len
endfunction

function! UniteStatusCur()
  if !exists('b:unite')
    return ''
  endif
  let cur = line('.') - 1
  let cur = cur < 0 ? 0 : cur
  return '   ' . cur . '/'
endfunction

function! UniteStatusPath()
  if !exists('b:unite')
    return ''
  endif
  return substitute(get(b:unite.msgs, 0, ''), '^\[.\{-}\]\s*', '', '')
endfunction


function! s:set_unite_statusline()
  hi UniteStatusCur   guifg=#E65100
  hi UniteStatusLInfo guifg=#E65100
  hi UniteStatusPath  guifg=#757575

  if !exists('b:unite')
    return ''
  endif
  let parts = [
        \ '%#UniteStatusCur#%{UniteStatusCur()}',
        \ '%#UniteStatusLInfo#%{UniteStatusLen()}',
        \ '%=',
        \ '%#UniteStatusPath#%{UniteStatusPath()}'
        \ ]
  exe 'setlocal statusline=' . join(parts, '')
endfunction


function! s:unite_settings()
  nmap <buffer> Q <plug>(unite_exit)
  nmap <silent><buffer><expr> gs unite#do_action('vsplit')
  nmap <silent><buffer><expr> s unite#do_action('split')
  call s:set_unite_statusline()
endfunction

augroup unite
  autocmd!
  autocmd FileType unite call s:unite_settings()
augroup END
