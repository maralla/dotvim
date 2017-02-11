let g:lightline = {
      \ 'colorscheme': 'mylightline',
      \ 'subseparator': {'left': ' ', 'right': ' '},
      \ 'active': {
      \   'left': [
      \     [],
      \     ['mode', 'paste', 'fugitive'],
      \     ['filename']
      \   ],
      \   'right': [
      \     ['validator'],
      \     ['lineinfo', 'tmux'],
      \     ['tagname', 'filetype']
      \   ]
      \ },
      \ 'inactive': {
      \   'right': [[], ['percent']],
      \ },
      \ 'component_function': {
      \   'mode': 'LightLineMode',
      \   'fugitive': 'LightLineFugitive',
      \   'filename': 'LightLineFilename',
      \   'filetype': 'LightLineFiletype',
      \   'lineinfo': 'LightLineLineinfo',
      \   'tagname': 'LightLineTagname',
      \   'tmux': 'LightLineTmux',
      \   'validator': 'LightLineValidator',
      \ },
      \ }

function! LightLineMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! LightLineFugitive()
  if winwidth(0) <= 70
    return ''
  endif

  let branch = exists('*fugitive#head') ? fugitive#head() : ''
  return branch !=# '' ? "\ue0a0 ".branch : ''
  " return branch !=# '' ? "\uf020 ".branch : ''
endfunction

function! LightLineFilename()
  let name = expand('%:t')
  let name = name !=# '' ? name : '[No Name]'
  if name =~? 'netrw'
    return 'netrw'
  endif

  let readonly = &readonly ? "\ue0a2 " : ''
  " let readonly = &readonly ? '⭤ ' : ''
  let modified = &modified ? ' +' : ''

  return readonly . name . modified
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? &ft : ''
endfunction

function! LightLineLineinfo()
  let msg = printf('%-4d:%-3d', line('.'), col('.'))
  return winwidth(0) > 70 ? "\ue0a1 ".msg : ''
  " return winwidth(0) > 70 ? '⭡ '.msg : ''
endfunction

function! LightLineTagname()
  return tagbar#currenttag('%s', '', '')
endfunction

function! LightLineTmux()
  if winwidth(0) <= 70
    return ''
  endif

  return $TERM == 'screen' && $TMUX != '' ? 'Tmux' : ''
endfunction

function! LightLineValidator()
  return winwidth(0) > 70 ? validator#get_status_string() : ''
endfunction
