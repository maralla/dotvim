let s:files = []
let s:prompt_indicator = '» '
let s:position = 'topleft'
let s:filename = '_@@_finder_@@_'
let s:inited = v:false
let s:just_open = v:true
let s:dir = getcwd()
let s:total = 0
let s:min_height = 10


func filefinder#start() abort
  call s:open_finder()
  if !s:inited
    call s:init()
  endif
  let path = s:find_git()
  call s:fetch_files(path)
  startinsert!
  call s:put_content(['Loading...'])
endfunc


func s:find_git()
  let cwd = getcwd()
  let p = cwd
  while v:true
    if isdirectory(p.'/.git')
      return p
    endif
    let p = fnamemodify(p, ':h')
    if p == '/'
      return cwd
    endif
  endwhile
endfunc


func s:fetch_files(cwd)
  if exists('s:job') && job_status(s:job) ==# 'run'
    call job_stop(s:job)
  endif
  let s:dir = a:cwd
  let s:job = job_start(['fd', '-t=f'], {
        \ 'close_cb': {c->s:on_data(c)},
        \ 'cwd': a:cwd,
        \ })
endfunc


func s:on_data(ch) abort
  let s:files = []
  let i = 0
  try
    while ch_canread(a:ch)
      let indent = printf('%*s', strchars(s:prompt_indicator), ' ')
      call add(s:files, indent . '#'.string(i).'#'.ch_read(a:ch))
      let i += 1
    endwhile
    call s:put_content(s:files)
  catch /E906/
    call s:close_finder()
    echohl Error
    echo 'Fail to run finder'
    echohl None
  endtry
endfunc


func s:put_content(content)
  setlocal modifiable
  let pos = getpos('.')
  let prompt = getline(1)
  let indicator_len = len(s:prompt_indicator)

  if s:just_open
    let prompt = s:prompt_indicator
    let s:just_open = v:false
    let pos[2] = indicator_len + 1
  elseif pos[2] - 1 <= indicator_len
    let prompt = s:prompt_indicator . substitute(prompt, '^'.s:prompt_indicator.'\?', '', '')
  endif
  normal! ggdG
  call append(line('$'), [prompt])
  call append(line('$'), a:content)
  let s:total = len(a:content)
  normal! ggdd
  call s:set_syntax()
  if len(prompt) <= indicator_len
    call cursor(1, 10000)
  else
    if pos[2] < indicator_len + 1
      let pos[2] = indicator_len + 1
    endif
    call setpos('.', pos)
  endif
  redraw!
endfunc


func s:set_syntax()
  hi filefinderCount guifg=#FF8F00 guibg=#212121
  hi filefinderDir guifg=#795548 guibg=#212121

  hi default link filefinderMatch Identifier
  hi default link filefinderEndMatch NONE
  syntax clear filefinderMatch
  syntax clear filefinderEndMatch
  syntax region filefinderMatch matchgroup=filefinderEndMatch start="\*\*" end="\*\*" concealends
  syntax match NONE "#\d\+#" conceal

  nnoremap <expr> <buffer> <silent> <CR> filefinder#_open_file()
  inoremap <expr> <buffer> <silent> <CR> filefinder#_open_file()
endfunc


func filefinder#_open_file()
  let c = line('.')
  if c == 1
    let content = getline(2)
  else
    let content = getline(c)
  endif
  try
    let [_, idx; _] = matchlist(content, '^\s*#\(\d\+\)#')
  catch /E688/
    return ''
  endtry
  let idx = str2nr(idx)
  let action = ''
  if len(s:files) > idx
    let path = s:dir . '/' . substitute(s:files[idx], '^\s*#\(\d\+\)#', '', '')
    let action = "\<ESC>:" . winnr('#') . "wincmd w\<CR>:edit " . path . "\<CR>:" . winnr() . "wincmd c\<CR>"
  endif
  return action
endfunc


func s:open_finder() abort
  let s:just_open = v:true
  let s:files = []
  let nr = bufwinnr(s:filename)
  if nr > 0
    exe 'silent ' . nr . ' wincmd w'
  elseif bufexists(s:filename)
    exe s:position . ' sbuffer ' . s:filename
  else
    exe 'silent ' . s:position . ' new' . s:filename
  endif
  call s:setup_statusline()
  exe 'resize '. float2nr(round(0.4*&lines))
endfunc

func s:close_finder() abort
  let nr = bufwinnr(s:filename)
  if nr > 0
    call feedkeys("\<ESC>")
    exe 'silent ' . nr . ' wincmd c'
  endif
endfunc

func s:init() abort
  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal nolist
  setlocal nobuflisted
  setlocal nocursorbind
  setlocal noscrollbind
  setlocal noswapfile
  setlocal nospell
  setlocal noreadonly
  setlocal nofoldenable
  setlocal nonumber
  setlocal foldcolumn=0
  setlocal iskeyword+=-,+,\\,!,~
  setlocal matchpairs-=<:>
  setlocal omnifunc=
  let b:completor_disabled = v:true
  match
  if has('conceal')
    setlocal conceallevel=2
    setlocal concealcursor=niv
  endif
  if exists('+cursorcolumn')
    setlocal nocursorcolumn
  endif
  if exists('+colorcolumn')
    setlocal colorcolumn=0
  endif
  if exists('+relativenumber')
    setlocal norelativenumber
  endif
  setlocal signcolumn=no
  setlocal winfixheight
  setfiletype finder

  nnoremap <silent> <buffer> i :startinsert<CR>
  nnoremap <silent> <buffer> A :startinsert!<CR>
  nnoremap <silent> <buffer> q :quit<CR>

  augroup filefinder
    autocmd! * <buffer>
    autocmd InsertEnter <buffer> call s:on_insert_enter()
    autocmd InsertLeave <buffer> call s:on_insert_leave()
    autocmd TextChangedI <buffer> call s:on_text_changed()
  augroup END
  let s:inited = v:true
endfunc


func s:on_insert_enter()
  setlocal modifiable
  let prompt = getline(1)
  let current_line = line('.')
  if current_line != 1
    call feedkeys("\<C-o>gg")
  endif
  if current_line != 1 || col('.') <= len(s:prompt_indicator)
    call setline(1, '')
    call feedkeys(prompt)
  endif
endfunc


func s:on_insert_leave()
  setlocal nomodifiable
endfunc


func s:on_text_changed()
  if empty(s:files)
    return
  endif
  let prompt = getline(1)
  let filter_text = escape(substitute(prompt, '^'.s:prompt_indicator.'\?', '', ''), '.')
  let filter_text = substitute(filter_text, '\*', '.*', 'g')
  let filtered = []
  if empty(filter_text)
    let filtered = s:files
  else
    for entry in s:files
      if entry =~ filter_text
        let idx = stridx(entry, '#', stridx(entry, '#')+1)
        if idx <= 0
          continue
        endif
        let f = substitute(entry[idx+1:], '\('.filter_text.'\)', '**\1**', 'g')
        call add(filtered, entry[:idx].f)
      endif
    endfor
  endif
  call s:put_content(filtered)
endfunc


func s:setup_statusline()
  let parts = [
        \ '%#filefinderCount#%{filefinder#_count()}',
        \ '%=',
        \ '%#filefinderDir#%{filefinder#_dir()}',
        \ ]
  exe 'setlocal statusline='.join(parts, '')
endfunc


func filefinder#_count()
  return '   ' . (line('.') - 1) . '/' . s:total
endfunc


func filefinder#_dir()
  return s:dir . '  '
endfunc
