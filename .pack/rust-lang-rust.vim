let g:rustfmt_autosave = 0

autocmd BufNewFile,BufRead *.rs setlocal colorcolumn=100
autocmd BufWritePre *.rs call rustfmt#Format()

let $RUST_SRC_PATH = '/Users/maralla/Workspace/src/rust/src'
