scriptencoding utf8

let s:inited = v:false
let s:dir = getcwd()
let s:total = 0
let s:timer = -1


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
  if filter == ''
    return
  endif
  let [run, args] = s:parse_args(args, filter)
  if !empty(run)
    call s:execute(run, args, a:render)
  endif
endfunc


func s:gen_find_cmd(cwd, options, filter)
  let s:dir = a:cwd
  let max_count = get(g:, 'finder_max_files', 100)
  let cmd = [
        \ '/bin/sh', '-c',
        \ join(['fd', '-p'] + a:options + [a:filter, '|', 'rg', '--json', '--max-count', max_count, a:filter], ' ')
        \ ]
  let args = #{cwd: a:cwd}
  return [cmd, args]
endfunc


func s:parse_args(args, filter)
  if a:args[1] == ''
    let cmd = ['', {}]
  else
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
    let cmd = s:gen_find_cmd(dir, options, a:filter)
  endif
  return cmd
endfunc


func s:execute(run, args, render)
  let opts = #{close_cb: {c->s:render_result(c, a:render)}}
  for [k, v] in items(a:args)
    let opts[k] = v
  endfor
  let s:job = job_start(a:run, opts)
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
