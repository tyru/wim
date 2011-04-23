" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" Interface {{{
function! wim#load() "{{{
    " dummy function to load this script.
endfunction "}}}

function! wim#open(q_args) "{{{
    let wim = s:create_wim()
    let nr = wim.open_buffer()
    if nr ==# -1
        call s:echomsg(
        \   'ErrorMsg',
        \   "wim: error: can't open wim buffer.")
        return
    endif
    call wim.setup_buffer()
    if !empty(a:q_args)
        call wim.open_url(a:q_args)
    endif
endfunction "}}}

" }}}


" Implementation {{{

function! s:echomsg(hl, msg) abort "{{{
    execute 'echohl' a:hl
    try
        echomsg a:msg
    finally
        echohl None
    endtry
endfunction "}}}


function! s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction
let s:SID_PREFIX = s:SID()
delfunction s:SID

function! s:local_func(name) "{{{
    return function('<SNR>' . s:SID_PREFIX . '_' . a:name)
endfunction "}}}


function! s:create_wim()
    return deepcopy(s:wim)
endfunction

function! s:wim_open_buffer() dict
    let nr = bufnr(self.BUFFER_NAME)
    if nr ==# -1
        try
            execute self.OPEN_BUFFER_COMMAND
            let nr = bufnr('%')
            silent file `=self.BUFFER_NAME`
        catch
            " TODO: any error message?
        endtry
    endif
    return nr
endfunction

function! s:wim_setup_buffer() dict
    " TODO
endfunction

function! s:wim_open_url(url) dict
    echo 'opening' a:url '...'
    echo 'opening' a:url '...Done.'
endfunction

let s:wim = {
\   'BUFFER_NAME': '___w_i_m___',
\   'OPEN_BUFFER_COMMAND': 'vnew',
\
\   'open_buffer': s:local_func('wim_open_buffer'),
\   'setup_buffer': s:local_func('wim_setup_buffer'),
\   'open_url': s:local_func('wim_open_url'),
\}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
