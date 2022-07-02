func json#pretty()
  pyx import json, vim
  pyx vim.current.buffer[:] = json.dumps(json.loads('\n'.join(vim.current.buffer)), indent=2, ensure_ascii=False).split('\n')

  set ft=json
endfunc
