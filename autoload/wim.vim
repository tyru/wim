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
    if !wim.buffer_exists()
        let nr = wim.open_buffer()
        if nr ==# -1
            call s:echomsg(
            \   'ErrorMsg',
            \   "wim: error: can't open wim buffer.")
            return
        endif
        call wim.setup_buffer()
    endif
    if !empty(a:q_args)
        call wim.open_url(a:q_args)
    endif
endfunction "}}}

" }}}


" Implementation {{{

" s:SID_PREFIX {{{
function! s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

let s:SID_PREFIX = s:SID()
delfunction s:SID
" }}}


function! s:echomsg(hl, msg) abort "{{{
    execute 'echohl' a:hl
    try
        echomsg a:msg
    finally
        echohl None
    endtry
endfunction "}}}

function! s:local_func(name) "{{{
    return function('<SNR>' . s:SID_PREFIX . '_' . a:name)
endfunction "}}}



function! s:create_wim(...) "{{{
    let wim = deepcopy(s:wim)
    if a:0 ==# 1 && type(a:1) ==# type({})
        let constant = '^[A-Z_]\+$'
        for _ in filter(keys(s:wim), 'v:val =~# constant')
            if has_key(a:1, _)
                let wim[_] = a:1[_]
            endif
        endfor
    endif
    return wim
endfunction "}}}

function! s:wim_open_buffer() dict "{{{
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
endfunction "}}}

function! s:wim_setup_buffer() dict "{{{
    " Options
    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal noswapfile

    " Keymappings
    nnoremap <Plug>(wim:open) :<C-u>WimOpen<Space>
    if !self.NO_DEFAULT_KEYMAPPINGS
        nmap o <Plug>(wim:open)
    endif

    " Load wim specific settings.
    setfiletype wim
endfunction "}}}

function! s:wim_open_url(url) dict "{{{
    redraw
    echo 'opening' a:url '...'

    " Get buffer text (via wwwrenderer.vim).
    let buffer_text = s:wim_get_buffer_text(a:url)
    if empty(buffer_text)
        return
    endif

    " Write the buffer text to wim buffer.
    if bufnr(self.BUFFER_NAME) ==# bufnr('%')
        call s:wim_render_buffer_text(buffer_text)
    endif

    redraw
    echo 'opening' a:url '...Done.'
endfunction "}}}

function! s:wim_get_buffer_text(url) "{{{
    try
        " let url = urilib#new_from_uri_like_string(a:url).to_string()
        return wwwrenderer#render(a:url)
    catch
        call s:echomsg('WarningMsg', 'wwwrenderer#render() throwed an exception.')
        call s:echomsg('WarningMsg', 'v:exception = '.v:exception)
        call s:echomsg('WarningMsg', 'v:throwpoint = '.v:throwpoint)
        return ''
    endtry
endfunction "}}}

function! s:wim_render_buffer_text(buffer_text) "{{{
    let save = &l:modifiable
    let &l:modifiable = 1
    try
        %delete _
        call setline(1, split(a:buffer_text, '\n'))
    catch
        let &l:modifiable = save
    endtry
endfunction "}}}

function! s:wim_buffer_exists() dict "{{{
    return bufnr(self.BUFFER_NAME) !=# -1
endfunction "}}}

let s:wim = {
\   'BUFFER_NAME': '___w_i_m___',
\   'OPEN_BUFFER_COMMAND': 'vnew',
\   'NO_DEFAULT_KEYMAPPINGS': 0,
\
\   'open_buffer': s:local_func('wim_open_buffer'),
\   'setup_buffer': s:local_func('wim_setup_buffer'),
\   'open_url': s:local_func('wim_open_url'),
\   'buffer_exists': s:local_func('wim_buffer_exists'),
\}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
