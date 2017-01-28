function! s:zen_html_tab()
  let line = getline('.')
  if match(line, '<.*>') < 0
    return "\<c-y>,"
  endif
  return "\<c-y>n"
endfunction

autocmd FileType xml,xsl,xslt,xsd,css,sass,scss,less,mustache imap <buffer><c-o> <c-y>,
autocmd FileType html,jinja imap <buffer><expr><c-o> <sid>zen_html_tab()
