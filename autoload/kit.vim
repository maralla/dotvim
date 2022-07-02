func kit#text() range
  call s:echo()
endfunc

def s:echo(): void
  let bak = @a
  let text = ''

  try
    silent! normal! gv"ay
    text = @a
  finally
    @a = bak
  endtry

  echo text
enddef
