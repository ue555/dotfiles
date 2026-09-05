let g:gruvbox_contrast_dark = 'medium'
set background=dark
try
  colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
  echohl WarningMsg
  echom 'vpm: gruvbox is not installed; run `vpmctl install`'
  echohl None
endtry

let g:airline_theme = 'gruvbox'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

let g:NERDTreeShowHidden = 1
let g:NERDTreeQuitOnOpen = 1
nnoremap <silent> <leader>e :NERDTreeToggle<CR>

let g:ctrlp_map = '<leader>ff'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
      \ 'dir': '\v[\/](\.git|node_modules|target|dist)$',
      \ 'file': '\v\.(o|so|dll|class)$',
      \ }
nnoremap <silent> <leader>fb :CtrlPBuffer<CR>

nnoremap <silent> <leader>gs :Git<CR>
nnoremap <silent> <leader>gb :Git blame<CR>

let g:gitgutter_map_keys = 0
nnoremap <silent> ]c :GitGutterNextHunk<CR>
nnoremap <silent> [c :GitGutterPrevHunk<CR>
nnoremap <silent> <leader>gp :GitGutterPreviewHunk<CR>

let g:ale_sign_error = 'E'
let g:ale_sign_warning = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_fix_on_save = 0
nnoremap <silent> <leader>an :ALENextWrap<CR>
nnoremap <silent> <leader>ap :ALEPreviousWrap<CR>
nnoremap <silent> <leader>af :ALEFix<CR>
