vim9script

def s:gen_cmd(t: string, ft: string): list<any>
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
    '--language', ft,
  ]
enddef


def codeimage#do(...lines: list<string>)
  let f = expand('%:p')
  let t = expand('%:p:t')

  let cmd = s:gen_cmd(t, &ft)

  let text = s:select()

  if text == ''
    cmd += [f]
  endif

  if !empty(lines)
    cmd += ['--highlight-lines', join(lines, ';')]
  endif

  let job = job_start(cmd)

  if text != ''
    let ch = job_getchannel(job)
    ch_sendraw(ch, text)
    ch_close_in(ch)
  endif
enddef


def s:select(): string
  let bak = @a
  let text = ''

  try
    silent! normal! gv"ay
    text = @a
  finally
    @a = bak
  endtry

  return text
enddef
