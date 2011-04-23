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



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
