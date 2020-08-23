scriptencoding utf8


func hunk#start()
  sign define HunkAdd text=+ texthl=HunkAddSign
  sign define HunkChange text=! texthl=HunkChangeSign
  hi default HunkAddSign guifg=#798508 guibg=#131313
  hi default HunkChangeSign guifg=#896E1D guibg=#131313
  hi default HunkDeleteSign guifg=#892C35 guibg=#131313

  augroup hunk
    autocmd BufReadPost  * call s:run()
    autocmd BufWritePost * call s:run()
  augroup END
  call s:run()
endfunc


func! s:cmd()
  let f = expand('%f')
  if empty(f)
    return ''
  endif
  return 'git diff -U0 ' . f . ' | grep @@'
endfunc

" @@ -3,0 +4,3 @@ import (
" @@ -4,0 +8,4 @@ import (
" @@ -8,19 +15,85 @@ func TestStream(t *testing.T) {
func! s:parse(hunk)
  let tokens = matchlist(a:hunk, '^@@ -\v(\d+),?(\d*) \+(\d+),?(\d*)')
  if empty(tokens)
    return []
  endif
  return [
        \ str2nr(tokens[1]),
        \ empty(tokens[2]) ? 1 : str2nr(tokens[2]),
        \ str2nr(tokens[3]),
        \ empty(tokens[4]) ? 1 : str2nr(tokens[4])
        \ ]
endfunc


" Hunks sign id base.
let s:id = 0

func s:get_sign_id()
  let s:id += 1
  return s:id
endfunc


func s:render(hunks)
  let nr = bufnr()
  let signs = []
  for hunk in a:hunks
    let parts = s:parse(hunk)
    if empty(parts)
      continue
    endif

    let [minus_line, minus_count, plus_line, plus_count] = parts
    if minus_count == 0 && plus_count > 0
      let line = plus_line
      while line - plus_line < plus_count
        call add(signs, #{
              \ id: s:get_sign_id(),
              \ line: line,
              \ name: 'HunkAdd',
              \ buffer: nr,
              \ })
        let line += 1
      endwhile
    endif

    if minus_count > 0 && plus_count == 0
      let msg = string(minus_count < 100 ? minus_count : '>')
      if plus_line != 0
        let name = 'HunkDelete' . msg
        call sign_define(name, #{
              \ text: msg,
              \ texthl: 'HunkDeleteSign',
              \ })
        call add(signs, #{
              \ id: s:get_sign_id(),
              \ line: plus_line,
              \ name: name,
              \ buffer: nr,
              \ })
      endif
    endif

    if minus_count > 0 && plus_count > 0
      let line = plus_line
      while line - plus_line < plus_count
        call add(signs, #{
              \ id: s:get_sign_id(),
              \ line: line,
              \ name: 'HunkChange',
              \ buffer: nr,
              \ })
        let line += 1
      endwhile
    endif

  endfor
  call s:place_sign(signs)
endfunc


let s:signs = {}

func s:place_sign(signs)
  for sign in a:signs
    call sign_place(sign.id, 'githunk', sign.name, sign.buffer, #{lnum: sign.line, priority: 1})
  endfor
  let nr = bufnr()
  let signs = get(s:signs, nr, [])
  if !empty(signs)
    for old in signs
      call sign_unplace('githunk', #{id: old.id, buffer: old.buffer})
    endfor
  endif
  let s:signs[nr] = a:signs
endfunc


func! s:run()
  let cmd = s:cmd()
  if empty(cmd)
    return
  endif
  if exists('s:job') && job_status(s:job) ==# 'run'
    call job_stop(s:job)
  endif
  let s:job = job_start(["/bin/sh", "-c", cmd], #{
        \ close_cb: function('s:on_data'),
        \ })
endfunc


func! s:on_data(ch)
  let data = []
  while ch_canread(a:ch)
    try
      call add(data, ch_read(a:ch))
    catch /E906/
      return
    endtry
  endwhile
  call s:render(data)
endfunc
