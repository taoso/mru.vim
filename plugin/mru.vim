let s:cpo_save = &cpo
set cpo&vim

if !exists('g:mru_file_list_size')
	let g:mru_file_list_size = 10
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

	execute 'edit '.expand(p, ':')
endfunction

function! s:List()
	let files = map(copy(g:MRU_FILE_LIST), 'fnamemodify(v:val, ":~:.")')
	let n = len(files)
	let row = n > 10 ? 10 : n
	execute 'keepalt below '.row.' new'
	setlocal buftype=nofile
	setlocal filetype=MRU
	let i = 0
	while i < n
		call setline(i+1, files[i])
		let i += 1
	endwhile
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

function! s:Remove(cpath)
	let idx = index(g:MRU_FILE_LIST, a:cpath)

	if idx == -1
		let idx = index(g:MRU_FILE_LIST, getcwd().'/'.a:cpath)
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

	autocmd FileType MRU nnoremap <silent> <buffer> <cr> :call mru#Open()<cr>
	autocmd FileType MRU nnoremap <silent> <buffer> <Esc> :bdelete<cr>
	autocmd FileType MRU nnoremap <silent> <buffer> <C-c> :bdelete<cr>
	autocmd FileType MRU nnoremap <silent> <buffer> <C-n> j
	autocmd FileType MRU nnoremap <silent> <buffer> <C-p> k
augroup END

command! Mru call s:List()

let &cpo = s:cpo_save
unlet s:cpo_save

