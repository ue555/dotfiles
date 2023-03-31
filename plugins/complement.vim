" 補完の設定
let g:lsp_diagnostics_echo_cursor=1
let g:lsp_text_edit_enabled=1
let g:asyncomplete_auto_popup=1
let g:asyncomplete_popup_delay=200

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
