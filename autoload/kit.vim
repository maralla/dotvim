func kit#text() range
  call Echo()
endfunc

def Echo(): void
  const bak = @a
  var text = ''

  try
    silent! normal! gv"ay
    text = @a
  finally
    @a = bak
  endtry

  echo text
enddef
