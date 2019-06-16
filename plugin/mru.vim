let s:cpo_save = &cpo
set cpo&vim

if !exists('g:mru_file_list_size')
	let g:mru_file_list_size = 7
end

if !exists('g:mru_ignore_patterns')
	let g:mru_ignore_patterns = 'fugitive\|\.git/\|\_^/tmp/'
end

function! mru#Open()
	let p = expand(getline('.'), ':p')
	bdelete

	if !filereadable(p)
		call s:Remove(p)
		return
	endif

	while &buftype != ""
		execute 'wincmd w'
	endwhile
	execute 'edit '.expand(p, ':')
endfunction

function! s:List()
	setlocal modifiable
	let files = map(copy(g:MRU_FILE_LIST), 'fnamemodify(v:val, ":~:.")')
	let n = len(files)
	let row = n > 7 ? 7 : n
	execute 'keepalt bo '.row.' new'
	setlocal buftype=nofile
	setlocal filetype=MRU
	setlocal colorcolumn=
	let i = 0
	while i < n
		call setline(i+1, files[i])
		let i += 1
	endwhile
	setlocal nomodifiable
endfunction

function! s:Add()
	let cpath = expand('%:p')
	if !filereadable(cpath)
		return
	endif

	if cpath =~# g:mru_ignore_patterns
		return
	end

	let idx = index(g:MRU_FILE_LIST, cpath)
	if idx >= 0
		call filter(g:MRU_FILE_LIST, 'v:val !=# cpath')
	endif
	call insert(g:MRU_FILE_LIST, cpath)
endfunction

function! s:ClearCurrentFile()
	let cpath = expand('%:p')
	call s:Remove(cpath)
endfunction

function! mru#RemoveCurrentFile()
	setlocal modifiable
	let path = expand(getline('.'), '%:p')
	call s:Remove(path)

	delete
	setlocal nomodifiable
endfunction

function! s:Remove(path)
	let idx = index(g:MRU_FILE_LIST, a:path)

	if idx == -1
		let idx = index(g:MRU_FILE_LIST, getcwd().'/'.a:path)
	end

	if idx >= 0
		call remove(g:MRU_FILE_LIST, idx)
	end
	let max_index = g:mru_file_list_size - 1
	let g:MRU_FILE_LIST = g:MRU_FILE_LIST[:max_index]
endfunction

if has('nvim')
	rsh
else
	set viminfo+=!
	if filereadable('~/.viminfo')
		rv
	endif
endif

if !exists('g:MRU_FILE_LIST')
	let g:MRU_FILE_LIST = []
endif

augroup Mru
	autocmd BufEnter * call s:ClearCurrentFile()
	autocmd BufWinLeave,BufWritePost * call s:Add()
	autocmd BufLeave * if &ft ==# 'MRU' | bdelete | endif

	autocmd FileType MRU nnoremap <silent> <buffer> <cr> :call mru#Open()<cr>
	autocmd FileType MRU nnoremap <silent> <buffer> <esc> :bdelete<cr>
	autocmd FileType MRU nnoremap <silent> <buffer> <c-c> :bdelete<cr>
	autocmd FileType MRU cnoremap <silent> <buffer> <c-c> <esc>:bdelete<cr>
	autocmd FileType MRU nnoremap <silent> <buffer> dd :call mru#RemoveCurrentFile()<cr>
	autocmd FileType MRU nnoremap <silent> <buffer> <c-n> j
	autocmd FileType MRU nnoremap <silent> <buffer> <c-p> k
	autocmd FileType MRU setlocal cursorline
	autocmd FileType MRU setlocal number
augroup END

command! Mru call s:List()

let &cpo = s:cpo_save
unlet s:cpo_save
