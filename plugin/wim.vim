" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if (exists('g:loaded_wim') && g:loaded_wim) || &cp
    finish
endif
let g:loaded_wim = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


command!
\   -nargs=*
\   WimOpen
\   call wim#open(<q-args>)

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
