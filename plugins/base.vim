" タミーナルを垂直分割して開く
noremap t<Left> :vert term<enter>
" ターミナルを水平分割して画面最下部にウィンドウを開く
noremap t<Down> :bo term<enter>
" ターミナルを水平分割して画面最上部にウィンドウを開く
noremap t<Up> :top term<enter>
" 自分で書いたチートシート(めも)の設定
let g:cheatsheet#cheat_file = '~/.cheatsheet.md'
