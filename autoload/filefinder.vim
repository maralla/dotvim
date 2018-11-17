let s:files = {}
let s:prompt_indicator = '» '
let s:position = 'topleft'
let s:filename = '__finder__'
let s:inited = v:false
let s:just_open = v:true
let s:dir = getcwd()
let s:total = 0
let s:min_height = 10
let s:indent_len = strchars(s:prompt_indicator)
let s:indent = printf('%*s', s:indent_len, ' ')


func! filefinder#start() abort
  pyx import vim
  call s:open_finder()
  call s:fetch()
  if !s:inited
    call s:init()
  endif
endfunc


func! s:fetch() abort
  startinsert!
  if !empty(s:files)
    call s:put_content(s:files)
  else
    let path = s:find_git()
    call s:fetch_files(path, v:false)
    call s:put_content({'Loading...': 0})
  endif
endfunc


func! s:find_git()
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


func! s:start_fetcher()
  call timer_start(10000, {t->s:fetch_files(s:dir, v:true)}, {'repeat': -1})
endfunc


func! s:fetch_files(cwd, by_fetcher)
  if exists('s:job') && job_status(s:job) ==# 'run'
    call job_stop(s:job)
  endif
  let s:dir = a:cwd
  let s:job = job_start(['fd', '-t=f'], {
        \ 'close_cb': {c->s:on_data(c, a:by_fetcher)},
        \ 'cwd': a:cwd,
        \ })
endfunc


func! s:on_data(ch, by_fetcher) abort
  let nr = bufwinnr(s:filename)
  try
    while ch_canread(a:ch)
      let f = ch_read(a:ch)
      if has_key(s:files, f)
        let weight = s:files[f]
      else
        let weight = 0
      endif
      let s:files[f] = weight
    endwhile
    if !a:by_fetcher
      call s:put_content(s:files)
    endif
  catch /E906/
    if !a:by_fetcher
      call s:close_finder()
      echohl Error
      echo 'Fail to run finder'
      echohl None
    endif
  endtry
endfunc


func! s:compare(x, y)
  if a:x[1] == a:y[1]
    return a:x[0] == a:y[0] ? 0 : a:x[0] > a:y[0] ? 1 : -1
  elseif a:x[1] < a:y[1]
    return 1
  else
    return -1
  endif
endfunc


func! s:put_content(content) abort
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
  " normal! ggdG
  pyx vim.current.buffer[:] = []
  let rows = items(a:content)
  call sort(rows, 's:compare')
  call map(rows, 's:indent . v:val[0]')
  call append(line('$'), [prompt])
  call append(line('$'), rows)
  let s:total = len(rows)
  " normal! ggdd
  pyx del vim.current.buffer[0]
  if len(prompt) <= indicator_len
    call cursor(1, 10000)
  else
    if pos[2] < indicator_len + 1
      let pos[2] = indicator_len + 1
    endif
    call setpos('.', pos)
  endif
endfunc


func! s:set_syntax()
  hi filefinderCount guifg=#FF8F00 guibg=#212121
  hi filefinderDir guifg=#795548 guibg=#212121

  hi default link filefinderMatch Identifier
  hi default link filefinderEndMatch NONE
  syntax clear filefinderMatch
  syntax clear filefinderEndMatch
  syntax region filefinderMatch matchgroup=filefinderEndMatch start="\*\*" end="\*\*" concealends
  syntax match NONE "#\d\+#" conceal
endfunc


func! s:get_path(line)
  let row = substitute(a:line, '\*\*\([^*]*\)\*\*', '\1', 'g')
  if len(row) > s:indent_len
    return row[s:indent_len:]
  endif
  return ''
endfunc


func! s:get_current_path()
  let c = line('.')
  return s:get_path(c == 1 ? getline(2) : getline(c))
endfunc


func! s:win_do(action)
  return "\<ESC>:" . winnr('#') . "wincmd w\<CR>" . a:action . "\<CR>:" . winnr() . "wincmd c\<CR>"
endfunc


func! filefinder#_new() abort
  let c = line('.')
  if c == 1
    let dir = s:dir
  else
    let subpath = s:get_path(getline(c))
    let dir = fnamemodify(s:dir . '/' . subpath, ':h')
  endif
  let path = input('Create file: ' . dir . '/')
  if empty(path)
    return ''
  endif
  let f = dir.'/'.path
  let suffix = f[len(s:dir)+1:]
  if !has_key(s:files, suffix)
    let s:files[suffix] = 0
  endif
  return s:win_do(':edit ' . f)
endfunc


func! filefinder#_rename() abort
  let subpath = s:get_current_path()
  if empty(subpath)
    return ''
  endif
  let dir = s:dir . '/'
  let res = input('Rename file: ' . dir, subpath)
  if res != subpath && !empty(res)
    call rename(dir . subpath, dir . res)
    call remove(s:files, subpath)
    if !has_key(s:files, res)
      let s:files[res] = 0
    endif
    return ":silent doautocmd TextChangedI\<CR>"
  endif
  return ''
endfunc


func! filefinder#_delete() abort
  let subpath = s:get_current_path()
  let path = s:dir . '/' . subpath
  let res = input('Delete file: ' . path . ' (y/[n]) ')
  if res ==? 'y'
    call delete(path)
    call remove(s:files, subpath)
    return ":silent doautocmd TextChangedI\<CR>"
  endif
  return ''
endfunc


func! filefinder#_open_file() abort
  let subpath = s:get_current_path()
  if empty(subpath)
    return ''
  endif
  let s:files[subpath] += 1
  return s:win_do(':edit ' . s:dir . '/' . subpath)
endfunc


func! s:open_finder() abort
  let s:just_open = v:true
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


func! s:close_finder() abort
  let nr = bufwinnr(s:filename)
  if nr > 0
    call feedkeys("\<ESC>")
    exe 'silent ' . nr . ' wincmd c'
  endif
endfunc


func! s:init() abort
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
  nnoremap <silent> <buffer> / <nop>
  nnoremap <silent> <buffer> ? <nop>
  nnoremap <expr> <silent> <buffer> <CR> filefinder#_open_file()
  nnoremap <expr> <silent> <buffer> n filefinder#_new()
  nnoremap <expr> <silent> <buffer> r filefinder#_rename()
  nnoremap <expr> <silent> <buffer> D filefinder#_delete()
  inoremap <expr> <silent> <buffer> <CR> filefinder#_open_file()
  call s:set_syntax()
  augroup filefinder
    autocmd! * <buffer>
    autocmd InsertEnter <buffer> call s:on_insert_enter()
    autocmd InsertLeave <buffer> call s:on_insert_leave()
    autocmd TextChangedI <buffer> call s:on_text_changed()
  augroup END
  call s:start_fetcher()
  let s:inited = v:true
endfunc


func! s:on_insert_enter()
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


func! s:on_insert_leave()
  setlocal nomodifiable
endfunc


func! s:refresh_content()
  if bufwinid(s:filename) == -1
    return
  endif
  let prompt = getline(1)
  let filter_text = escape(substitute(prompt, '^'.s:prompt_indicator.'\?', '', ''), '.')
  let filter_text = substitute(filter_text, '\*', '.*', 'g')
  let filtered = {}
  if empty(filter_text)
    let filtered = s:files
  else
    for [entry, weight] in items(s:files)
      if entry =~ filter_text
        let f = substitute(entry, '\('.filter_text.'\)', '**\1**', 'g')
        let filtered[f] = weight
      endif
    endfor
  endif
  call s:put_content(filtered)
endfunc


func! s:on_text_changed()
  if empty(s:files)
    return
  endif
  if exists('s:timer')
    call timer_stop(s:timer)
  endif
  let timer = timer_start(200, {t -> s:refresh_content()})
endfunc


func! s:setup_statusline()
  let parts = [
        \ '%#filefinderCount#%{filefinder#_count()}',
        \ '%=',
        \ '%#filefinderDir#%{filefinder#_dir()}',
        \ ]
  exe 'setlocal statusline='.join(parts, '')
endfunc


func! filefinder#_count()
  return '   ' . (line('.') - 1) . '/' . s:total
endfunc


func! filefinder#_dir()
  return s:dir . '  '
endfunc
