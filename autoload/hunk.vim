vim9script
scriptencoding utf8

var base_hunk_ref = ''


export def Start()
  sign define HunkAdd text=+ texthl=HunkAddSign
  sign define HunkChange text=! texthl=HunkChangeSign
  hi default HunkAddSign guifg=#798508 guibg=#131313 ctermfg=100 ctermbg=233
  hi default HunkChangeSign guifg=#896E1D guibg=#131313 ctermfg=94 ctermbg=233
  hi default HunkDeleteSign guifg=#892C35 guibg=#131313 ctermfg=88 ctermbg=233

  augroup hunk
    autocmd BufReadPost  * Run()
    autocmd BufWritePost * Run()
  augroup END
  Run()
enddef


export def SetBase(b: string)
  base_hunk_ref = b
enddef


def GenCmd(): string
  const f = expand('%f')
  if empty(f)
    return ''
  endif
  return 'git diff -U0 ' .. base_hunk_ref .. ' ' .. f .. ' | grep @@'
enddef

# @@ -3,0 +4,3 @@ import (
# @@ -4,0 +8,4 @@ import (
# @@ -8,19 +15,85 @@ func TestStream(t *testing.T) {
def Parse(hunk: string): list<number>
  const tokens = matchlist(hunk, '^@@ -\v(\d+),?(\d*) \+(\d+),?(\d*)')
  if empty(tokens)
    return []
  endif

  return [
    str2nr(tokens[1]),
    empty(tokens[2]) ? 1 : str2nr(tokens[2]),
    str2nr(tokens[3]),
    empty(tokens[4]) ? 1 : str2nr(tokens[4])
  ]
enddef


# Hunks sign id base.
var sign_id = 0

def GetSignId(): number
  sign_id += 1
  return sign_id
enddef


def Render(hunks: list<string>)
  const nr = bufnr()
  var items = []

  for hunk in hunks
    const parts = Parse(hunk)
    if empty(parts)
      continue
    endif

    const [minusLine, minusCount, plusLine, plusCount] = parts

    if minusCount == 0 && plusCount > 0
      var line = plusLine
      while line - plusLine < plusCount
        add(items, {
          id: GetSignId(),
          line: line,
          name: 'HunkAdd',
          buffer: nr,
        })

        line += 1
      endwhile
    endif

    if minusCount > 0 && plusCount == 0
      const msg = minusCount < 100 ? string(minusCount) : '>'
      if plusLine != 0
        const name = 'HunkDelete' .. msg

        sign_define(name, {
          text: msg,
          texthl: 'HunkDeleteSign',
        })

        add(items, {
          id: GetSignId(),
          line: plusLine,
          name: name,
          buffer: nr,
        })
      endif
    endif

    if minusCount > 0 && plusCount > 0
      var line = plusLine
      while line - plusLine < plusCount
        add(items, {
          id: GetSignId(),
          line: line,
          name: 'HunkChange',
          buffer: nr,
        })

        line += 1
      endwhile
    endif
  endfor

  PlaceSign(items)
enddef


var signs = {}

def PlaceSign(items: list<dict<any>>)
  for sign in items
    sign_place(sign.id, 'githunk', sign.name, sign.buffer, {lnum: sign.line, priority: 1})
  endfor

  const nr = bufnr()
  const nrSigns = get(signs, nr, [])

  for old in nrSigns
    sign_unplace('githunk', {id: old.id, buffer: old.buffer})
  endfor

  signs[nr] = items
enddef


var currentJob = null_job

def Run()
  const cmd = GenCmd()
  if empty(cmd)
    return
  endif

  if currentJob != null_job && currentJob->job_status() =~ 'run'
    currentJob->job_stop()
  endif

  currentJob = job_start(["/bin/sh", "-c", cmd], {
    close_cb: function('OnData')
  })
enddef


def OnData(ch: channel)
  var data = []

  while ch_canread(ch)
    try
      add(data, ch_read(ch))
    catch /E906/
      return
    endtry
  endwhile

  Render(data)
enddef
