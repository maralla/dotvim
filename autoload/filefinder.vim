scriptencoding utf8

let s:inited = v:false
let s:dir = getcwd()
let s:total = 0
let s:timer = -1
let s:current = []
let s:operation = ''
let s:current_cursor = 1


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
  if len(parts) == 1 && parts[0] !~ '^\+'
    let args = '+.'
    let filter = cmd
  else
    let args = parts[0]
    let filter = trim(cmd[len(args):])
  endif
  if filter == ''
    return
  endif
  let [run, args, Fmt] = s:parse_args(args, filter)
  if !empty(run)
    call s:execute(run, args, a:render, Fmt)
  endif
endfunc


func s:max_count()
  return get(g:, 'finder_max_files', 100)
endfunc


func s:gen_find_cmd(cwd, options, filter)
  let s:dir = a:cwd
  let cmd = [
        \ '/bin/sh', '-c',
        \ join(['fd', '-p'] + a:options + [a:filter, '|', 'rg', '--json', '--max-count', s:max_count(), a:filter], ' ')
        \ ]
  let args = #{cwd: a:cwd}
  return [cmd, args, function('s:find_fmt')]
endfunc


func s:find_fmt(item)
  let data = #{
        \ text: trim(a:item.data.lines.text),
        \ matches: a:item.data.submatches,
        \ lnum: a:item.data.line_number,
        \ pathprops: [],
        \ }
  let data.path = data.text
  return data
endfunc


func s:rg_fmt(item)
  let data = #{
        \ matches: a:item.data.submatches,
        \ path: a:item.data.path.text,
        \ lnum: a:item.data.line_number,
        \ }
  let text = get(a:item.data.lines, 'text', '')
  if text == ''
    return {}
  endif
  let p = data.path[len(s:dir)+1:]
  if p == ''
    let p = '.'
  endif
  let line = a:item.data.line_number
  let path = p
  let p .= ':'. line . ': '
  if text[-1:] == "\n"
    let text = text[0:-2]
  endif
  let data.text = p . text
  let size = strlen(p)
  for k in data.matches
    let k.start += size
    let k.end += size
  endfor
  let pathprop = #{
        \ col: 1,
        \ length: strlen(path),
        \ type: 'finder_path',
        \ }
  let line_length = strlen(string(line))
  let lineprop = #{
        \ col: pathprop.length+2,
        \ length: line_length,
        \ type: 'finder_line_number',
        \ }
  let data.pathprops = [pathprop, lineprop]
  return data
endfunc


func s:gen_path(cwd, pattern)
  if a:pattern == ''
    return a:cwd
  endif
  if a:pattern =~ '^/'
    return a:pattern
  endif
  return a:cwd . '/' . a:pattern
endfunc


func s:parse_args(args, filter)
  let project_path = s:find_git()
  if a:args[1] == 'g'
    let s:operation = 'rg'
    let opts = #{cwd: s:gen_path(project_path, a:args[2:])}
    let s:dir = opts.cwd
    let action = ['rg', '-i', '--json', '--max-count', s:max_count(), a:filter, opts.cwd]
    let cmd = [action, opts, function('s:rg_fmt')]
  else
    let s:operation = 'fd'
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
    let dir = s:gen_path(project_path, sub)
    let cmd = s:gen_find_cmd(dir, options, a:filter)
  endif
  return cmd
endfunc


func s:execute(run, args, render, fmt)
  if has_key(a:args, 'cwd') && !isdirectory(a:args.cwd)
    return
  endif
  let opts = #{close_cb: {c->s:render_result(c, a:render, a:fmt)}}
  for [k, v] in items(a:args)
    let opts[k] = v
  endfor
  let s:job = job_start(a:run, opts)
endfunc


func s:render_result(ch, render, fmt) abort
  let data = []
  let num = 0
  while ch_canread(a:ch) && num < s:max_count()
    try
      let f = ch_read(a:ch)
    catch /E906/
      return
    endtry
    let item = json_decode(f)
    if item.type != 'match'
      continue
    endif
    let d = a:fmt(item)
    if len(d) == 0
      continue
    endif
    let data = add(data, d)
    let num += 1
  endwhile
  let s:total = 0
  call a:render(data)
endfunc


func s:init_props()
  hi default finderMatches guifg=#599BD9 cterm=bold
  hi default finderCursorPosition guibg=#3A484C
  hi default finderPrompt guibg=#161616
  hi default finderPromptSplitter guifg=#2E393C guibg=#1C2325
  hi default finderPromptBorder guifg=#404D4F guibg=#161616
  hi default finderPath guifg=#AD2584
  hi default finderLineNumber guifg=#217100

  call prop_type_add('finder_matches', #{highlight: 'finderMatches'})
  call prop_type_add('finder_cursor', #{highlight: 'finderCursorPosition'})
  call prop_type_add('finder_path', #{highlight: 'finderPath'})
  call prop_type_add('finder_line_number', #{highlight: 'finderLineNumber'})
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


func s:action_enabled()
  return s:operation == 'fd'
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
  elseif a:key == "\x80PS" || a:key == "\x80PE"
    " Remove bracketed-paste characters. :h t_PE
    return 1
  elseif a:key == "\<ESC>"
    call s:prompt_popup_close()
    call s:info_popup_close()
    let s:action = ''
    return 1
  elseif a:key == "\<C-r>"
    if !s:action_enabled() || s:action == 'rename'
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
    if !s:action_enabled() || s:action == 'new'
      return 1
    endif
    let text = s:popup_start_new_file() . ' '
    let s:prompt_popup_pos = strlen(text)
    let render = v:false
  elseif a:key == "\<C-d>"
    if !s:action_enabled() || s:action == 'remove'
      return 1
    endif
    let text = s:popup_start_remove_file() . ' '
    let s:prompt_popup_pos = strlen(text)
    let render = v:false
  elseif a:key == "\<CR>"
    if s:operation == 'rg'
      call s:rg_open()
    elseif s:action == 'rename'
      call s:popup_rename_file()
    elseif s:action == 'new'
      call s:popup_new_file()
    elseif s:action == 'remove'
      call s:popup_remove_file()
    else
      call s:popup_open_file()
    endif
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
    let s:prompt_popup = -1
  endif
  set cursorline
  exe 'set t_ve='.s:t_ve
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
        \ callback: function('s:prompt_callback')
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


func s:prompt_callback(id, result)
  if a:result == -1
    call s:prompt_popup_close()
    call s:info_popup_close()
    let s:action = ''
  endif
endfunc


func s:info_popup_getlnum()
  if s:info_popup == -1
    return 0
  endif
  let nr = winbufnr(s:info_popup)
  let info = getbufinfo(nr)
  return info[0].signs[0].lnum
endfunc


func s:info_popup_getline()
  let lnum = s:info_popup_getlnum()
  if lnum == 0
    return ''
  endif
  let nr = winbufnr(s:info_popup)
  let content = getbufline(nr, lnum)
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


func s:info_filter(id, key)
  if a:key == "\<DOWN>" || a:key == "\<C-j>" || a:key == "\<C-n>"
    call s:info_popup_do("normal! j")
    return 1
  elseif a:key == "\<UP>" || a:key == "\<C-k>" || a:key == "\<C-p>"
    call s:info_popup_do("normal! k")
    return 1
  endif
  return 0
endfunc


let s:info_popup = -1
func s:render_popup(data)
  call s:info_popup_close()
  if len(a:data) <= 0
    return
  endif
  let s:current = a:data
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
        \ filter: function('s:info_filter'),
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
    for p in item.pathprops
      call prop_add(i, p.col, #{length: p.length, type: p.type, bufnr: nr})
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


func s:rg_open()
  let lnum = s:info_popup_getlnum()
  if lnum == 0
    return
  endif
  let data = s:current[lnum-1]
  call s:prompt_popup_close()
  call s:info_popup_close()
  call feedkeys("\<ESC>:" . s:last_winnr . "wincmd w\<CR>:edit " . data.path . "\<CR>:" . data.lnum . "\<CR>")
endfunc
