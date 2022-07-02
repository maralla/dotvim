vim9script

def GenCmd(t: string, ft: string): list<string>
  return [
    'silicon',
    '-o', t .. '.png',
    '--background', '#fff0',
    '--pad-vert', '0',
    '--pad-horiz', '0',
    '--no-round-corner',
    '--no-line-number',
    '--no-window-controls',
    '--theme', 'Nord',
    # '-f', 'Ubuntu Mono; Noto Sans Mono CJK SC',
    '--language', ft,
  ]
enddef


export def Do(...lines: list<string>)
  const f = expand('%:p')
  const t = expand('%:p:t')

  var cmd = GenCmd(t, &ft)
  const text = Select()

  if text == ''
    cmd += [f]
  endif

  if !empty(lines)
    cmd += ['--highlight-lines', join(lines, ';')]
  endif

  if text != ''
    const job = job_start(cmd)
    const ch = job_getchannel(job)
    ch_sendraw(ch, text)
    ch_close_in(ch)
  endif
enddef


def Select(): string
  const bak = @a
  var text = ''

  try
    silent! normal! gv"ay
    text = @a
  finally
    @a = bak
  endtry

  return text
enddef
