scriptencoding utf8

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
let s:timer = -1


func! filefinder#start() abort
  pyx import vim
  call s:open_finder()
  if !s:inited
    call s:init()
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
    if p ==# '/'
      return cwd
    endif
  endwhile
endfunc


func s:render_prompt(cmd)
  let data = s:prompt_indicator
  if a:cmd != ""
    let data .= a:cmd
  endif
  call setline(1, [data])
  call feedkeys("\<ESC>ggA")
endfunc


func s:refresh()
  let size = len(s:prompt_indicator)
  let cmdline = getline(1)
  if cmdline[:size-1] != s:prompt_indicator
    let cmdline = s:prompt_indicator
  endif
  let cmd = cmdline[size:]
  call s:reset()
  call s:render_prompt(cmd)
  call s:delayed_find(cmd, function('s:render_pane'))
endfunc


func s:reset()
  pyx vim.current.buffer[:] = []
endfunc


func s:delayed_find(cmd, render)
  if s:timer != -1
    call timer_stop(s:timer)
  endif
  let s:timer = timer_start(200, {t -> s:find(a:cmd, a:render)})
endfunc


func s:find(cmd, render)
  if exists('s:job') && job_status(s:job) ==# 'run'
    call job_stop(s:job)
  endif
  let cmd = trim(a:cmd)
  if cmd == ""
    return
  endif
  if cmd[0] != '+'
    let cmd = '+. ' . cmd
  endif
  let parts = split(cmd, '\s\+')
  if len(parts) == 1
    let args = '+.'
    let filter = cmd
  else
    let args = parts[0]
    let filter = trim(cmd[len(args):])
  endif
  let [options, dir] = s:parse_args(args)
  if filter == ''
    return
  endif
  call s:execute(dir, options, filter, a:render)
endfunc


func s:parse_args(args)
  let options = ['--type=f']
  let sub = ''
  if a:args[1] == 'a'
    let options = options + ['--no-ignore', '--hidden']
    let sub = a:args[2:]
  elseif a:args[1] == 'h'
    let options = options + ['--hidden']
    let sub = a:args[2:]
  else
    let sub = a:args[1:]
  endif
  if sub =~ '^/'
    let dir = sub
  else
    let dir = s:find_git() . '/' . sub
  endif
  return [options, dir]
endfunc


func s:execute(cwd, options, filter, render)
  let s:dir = a:cwd
  let max_count = get(g:, 'finder_max_files', 100)
  let cmd = ['fd', '-p'] + a:options + [a:filter, '|', 'rg', '--json', '--max-count', max_count, a:filter]
  let s:job = job_start(['/bin/sh', '-c', join(cmd, ' ')], #{
        \ close_cb: {c->s:render_result(c, a:render)},
        \ cwd: a:cwd,
        \ })
endfunc


func s:render_result(ch, render) abort
  let data = []
  while ch_canread(a:ch)
    try
      let f = ch_read(a:ch)
    catch /E906/
      return
    endtry
    let item = json_decode(f)
    if item.type != 'match'
      continue
    endif
    let data = add(data, #{
          \ text: trim(item.data.lines.text),
          \ matches: item.data.submatches,
          \ })
  endwhile
  let s:total = 0
  call a:render(data)
endfunc


func s:render_pane(data)
  let pad = strdisplaywidth(s:prompt_indicator)
  for item in a:data
    let s:total += 1
    call append(line('$'), repeat(' ', pad) . item.text)
    for m in item.matches
      call prop_add(line('$'), m.start+1+pad, #{
            \ length: m.end - m.start,
            \ type: 'finder_matches',
            \ })
    endfor
  endfor
endfunc


func s:init_props()
  hi default link finderMatches Identifier
  call prop_type_add('finder_matches', #{
        \ highlight: 'finderMatches',
        \ })
  hi default finderCursorPosition guibg=#3A484C
  call prop_type_add('finder_cursor', #{
        \ highlight: 'finderCursorPosition',
        \ })
  hi default finderPrompt guibg=#161616
  hi default finderPromptSplitter guifg=#2E393C guibg=#1C2325
  hi default finderPromptBorder guifg=#63787A guibg=#161616
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
endfunc


func! s:get_path(line)
  let row = substitute(a:line, '\*\*\([^*]*\)\*\*', '\1', 'g')
  if len(row) > s:indent_len
    return row[s:indent_len :]
  endif
  return ''
endfunc


func! s:get_current_path()
  let c = line('.')
  let path = c == 1 ? getline(2) : getline(c)
  return trim(path)
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
  " let s:files[subpath] += 1
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
  let s:total = 0
  let s:dir = '.'
  setlocal modifiable
  call s:reset()
  call s:render_prompt('')
  setlocal nomodifiable
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
  call s:init_props()
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


func! s:on_text_changed()
  call s:refresh()
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





" Experiments


let s:prompt_popup_pos = 1
func s:prompt_popup_forward(max)
  if s:prompt_popup_pos < a:max
    let s:prompt_popup_pos += 1
  endif
endfunc

func s:prompt_popup_backward()
    if s:prompt_popup_pos > 1
      let s:prompt_popup_pos -= 1
    endif
endfunc

func s:prompt_popup_insert(text, key)
  let end = s:prompt_popup_pos - 2
  if end < 0
    let prefix = ''
  else
    let prefix = a:text[:end]
  endif
  return prefix . a:key . a:text[s:prompt_popup_pos-1:]
endfunc

func s:prompt_popup_delete(text)
  let p = s:prompt_popup_pos - 2
  if p < 0
    return a:text
  endif
  if p == 0
    let prefix = ''
  else
    let prefix = a:text[:p-1]
  endif
  return prefix . a:text[p+1:]
endfunc

func s:prompt_stop_move(input)
  if s:action ==# 'remove'
    return v:true
  endif
  if s:action !=# 'rename' && s:action !=# 'new'
    return v:false
  endif
  let text = a:input[:s:prompt_popup_pos-2]
  return text =~ '^+\p $'
endfunc


func s:prompt_stop_all(key)
  return s:action ==# 'remove' && a:key != "\<CR>" && a:key != "\<ESC>"
endfunc


func s:is_action()
  return s:action != ''
endfunc

let s:action = ''
func s:prompt_filter(id, key)
  if s:prompt_stop_all(a:key)
    return 1
  endif
  let nr = winbufnr(a:id)
  let content = getbufline(nr, 1)
  if len(content) <= 0
    let text = ''
  else
    let text = content[0]
  endif
  let move = v:false
  let render = !s:is_action()
  if a:key == "\<BS>"
    if s:prompt_stop_move(text)
      return 1
    endif
    let text = s:prompt_popup_delete(text)
    call s:prompt_popup_backward()
  elseif a:key == "\<ESC>"
    call s:prompt_popup_close()
    call s:info_popup_close()
    let s:action = ''
    return 1
  elseif a:key == "\<C-r>"
    if s:action == 'rename'
      return 1
    endif
    let f = s:popup_start_rename_file()
    if f == ''
      return 1
    endif
    let text = f . ' '
    let s:prompt_popup_pos = strlen(text)
    let render = v:false
  elseif a:key == "\<C-f>"
    if s:action == 'new'
      return 1
    endif
    let text = s:popup_start_new_file() . ' '
    let s:prompt_popup_pos = strlen(text)
    let render = v:false
  elseif a:key == "\<C-d>"
    if s:action == 'remove'
      return 1
    endif
    let text = s:popup_start_remove_file() . ' '
    let s:prompt_popup_pos = strlen(text)
    let render = v:false
  elseif a:key == "\<CR>"
    if s:action == 'rename'
      call s:popup_rename_file()
    elseif s:action == 'new'
      call s:popup_new_file()
    elseif s:action == 'remove'
      call s:popup_remove_file()
    else
      call s:popup_open_file()
    endif
    return 1
  elseif a:key == "\<DOWN>" || a:key == "\<C-j>" || a:key == "\<C-n>"
    call s:info_popup_do("normal! j")
    return 1
  elseif a:key == "\<UP>" || a:key == "\<C-k>" || a:key == "\<C-p>"
    call s:info_popup_do("normal! k")
    return 1
  elseif a:key == "\<LEFT>" || a:key == "\<C-h>"
    if s:prompt_stop_move(text)
      return 1
    endif
    call s:prompt_popup_do(a:id, "normal! h")
    call s:prompt_popup_backward()
    let move = v:true
    let render = v:false
  elseif a:key == "\<RIGHT>" || a:key == "\<C-l>"
    call s:prompt_popup_do(a:id, "normal! l")
    call s:prompt_popup_forward(strlen(text))
    let move = v:true
    let render = v:false
  elseif a:key !~ '\p'
    return 1
  else
    let text = s:prompt_popup_insert(text, a:key)
    call s:prompt_popup_forward(strlen(text))
  endif
  call prop_remove(#{id: s:prop_id_cursor, bufnr: nr, all: v:true}, 1)
  if !move
    call s:info_popup_close()
    call setbufline(nr, 1, text)
  endif
  call prop_add(1, s:prompt_popup_pos, #{
        \ length: 1,
        \ bufnr: nr,
        \ id: s:prop_id_cursor,
        \ type: 'finder_cursor'
        \ })
  if render
    call s:delayed_find(trim(text), function('s:render_popup'))
  endif
  return 1
endfunc

func s:prompt_popup_close()
  if s:prompt_popup != -1
    call popup_close(s:prompt_popup)
    set cursorline
    exe 'set t_ve='.s:t_ve
    let s:prompt_popup = -1
  endif
endfunc


func s:prompt_popup_set_title(title)
  if s:prompt_popup == -1
    return
  endif
  call popup_setoptions(s:prompt_popup, #{title: a:title, padding: [1, 1, 1, 1]})
endfunc


func s:prompt_popup_settext(cmd, text)
  if s:prompt_popup == -1
    return
  endif
  let prefix = (a:cmd == '') ? '' : a:cmd . ' '
  let text = prefix . a:text . ' '
  let s:prompt_popup_pos = strlen(text)
  call popup_settext(s:prompt_popup, text)
  call prop_add(1, s:prompt_popup_pos, #{
        \ length: 1,
        \ bufnr: winnr(s:prompt_popup),
        \ id: s:prop_id_cursor,
        \ type: 'finder_cursor'
        \ })
endfunc


func s:prompt_popup_gettext()
  if s:prompt_popup == -1
    return ''
  endif
  return trim(getbufline(winbufnr(s:prompt_popup), 1)[0])
endfunc


func s:prompt_popup_do(id, cmd)
  call win_execute(a:id, a:cmd)
endfunc


let s:prop_id_cursor = 1

let s:t_ve = &t_ve

let s:last_winnr = -1
let s:prompt_popup = -1
let s:inited = v:false
func filefinder#create_prompt()
  if !s:inited
    call s:init_props()
    let s:inited = v:true
  endif
  let s:last_winnr = winnr()
  set nocursorline
  set t_ve=
  let s:prompt_popup = popup_create(' ', #{
        \ line: 2,
        \ padding: [0, 1, 0, 1],
        \ minwidth: &columns*3/5,
        \ maxwidth: &columns*3/5,
        \ minheight: 1,
        \ maxheight: 1,
        \ mapping: v:false,
        \ highlight: 'finderPrompt',
        \ border: [1, 1, 1, 1],
        \ borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \ borderhighlight: ['finderPromptBorder'],
        \ filter: function('s:prompt_filter'),
        \ })
  let nr = winbufnr(s:prompt_popup)
  let s:prompt_popup_pos = 1
  call prop_add(1, s:prompt_popup_pos, #{
        \ length: 1,
        \ bufnr: nr,
        \ id: s:prop_id_cursor,
        \ type: 'finder_cursor',
        \ })
endfunc


func s:info_popup_getline()
  if s:info_popup == -1
    return ""
  endif
  let nr = winbufnr(s:info_popup)
  let info = getbufinfo(nr)
  let content = getbufline(nr, info[0].signs[0].lnum)
  return content[0]
endfunc


func s:info_popup_close()
  if s:info_popup != -1
    call popup_close(s:info_popup)
    let s:info_popup = -1
  endif
  if s:prompt_popup != -1
    call popup_setoptions(s:prompt_popup, #{
          \ borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
          \ })
  endif
endfunc


func s:info_popup_do(cmd)
  if s:info_popup == -1
    return
  endif
  call win_execute(s:info_popup, a:cmd)
endfunc


let s:info_popup = -1
func s:render_popup(data)
  call s:info_popup_close()
  if len(a:data) <= 0
    return
  endif
  let s:info_popup = popup_create(a:data, #{
        \ line: 5,
        \ padding: [1, 1, 1, 1],
        \ minwidth: &columns*3/5,
        \ maxwidth: &columns*3/5,
        \ border: [0, 1, 1, 1],
        \ borderchars: ['─', '│', '─', '│', '╭', '┐', '┘', '└'],
        \ cursorline: 1,
        \ scrollbar: 0,
        \ mapping: v:false,
        \ highlight: 'finderPrompt',
        \ borderhighlight: ['finderPromptBorder'],
        \ })
  call popup_setoptions(s:prompt_popup, #{
        \ borderchars: ['─', '│', '─', '│', '┌', '┐', '┤', '├'],
        \ })
  let nr = winbufnr(s:info_popup)
  let i = 1
  for item in a:data
    for m in item.matches
      call prop_add(i, m.start+1, #{
            \ length: m.end - m.start,
            \ type: 'finder_matches',
            \ bufnr: nr,
            \ })
    endfor
    let i += 1
  endfor
endfunc


func s:popup_open_file()
  let line = s:info_popup_getline()
  if line == ""
    return
  endif
  call s:prompt_popup_close()
  call s:info_popup_close()
  let file = s:dir . '/' . line
  call feedkeys("\<ESC>:" . s:last_winnr . "wincmd w\<CR>:edit " . file . "\<CR>")
endfunc


func s:popup_start_rename_file()
  let line = s:info_popup_getline()
  if trim(line) == ''
    return ''
  endif
  let s:action = 'rename'
  call s:prompt_popup_set_title(' RENAME')
  let s:rename_from = line
  return '+: ' . line
endfunc


func s:popup_rename_file()
  let p = s:prompt_popup_gettext()
  if p =~ '^+: ' && s:rename_from != ''
    let to = trim(p[2:])
    if to != ''
      let d = s:dir . '/'
      call rename(d . s:rename_from, d . to)
    endif
  endif
  call s:prompt_popup_close()
  let s:action = ''
endfunc


func s:popup_start_new_file()
  let s:action = 'new'
  call s:prompt_popup_set_title(' NEW')
  let line = s:info_popup_getline()
  return '+: ' . fnamemodify(line, ':h') . '/'
endfunc


func s:popup_new_file()
  let p = s:prompt_popup_gettext()
  if p =~ '^+: '
    let name = trim(p[2:])
    if name != '' && name != '.' && name != '..'
      let name = s:dir . '/' . name
      call s:prompt_popup_close()
      let dir = fnamemodify(name, ':h')
      if !isdirectory(dir)
        call mkdir(dir, "p")
      endif
      let s:action = ''
      call feedkeys("\<ESC>:" . s:last_winnr . "wincmd w\<CR>:edit " . name . "\<CR>")
      return
    endif
  endif
  call s:prompt_popup_close()
  let s:action = ''
endfunc


func s:popup_start_remove_file()
  let line = s:info_popup_getline()
  if trim(line) == ''
    return ''
  endif
  let s:action = 'remove'
  call s:prompt_popup_set_title(' REMOVE')
  return '+: ' . line
endfunc


func s:popup_remove_file()
  let p = s:prompt_popup_gettext()
  if p =~ '^+: '
    let name = trim(p[2:])
    if name != ''
      call delete(s:dir . '/' . name)
    endif
  endif
  call s:prompt_popup_close()
  let s:action = ''
endfunc
