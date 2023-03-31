" ale
" php-cs-fixerへのパス
let g:ale_php_php_cs_fixer_executable='/opt/homebrew/bin/php-cs-fixer'
" phpのコード整形はphp_cs_fixerを利用するように指定(「-」ではなく「_」であるのに注意)
let g:ale_fixers = {'php': ['php_cs_fixer']}
" 保存時にコード整形を実行
let g:ale_fix_on_save = 1
