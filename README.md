# fzf-mru

Most Recently Used File List for Vim/NeoVim.

# Install

```viml
Plug 'lvht/mru'


" set max lenght for the mru file list
let g:mru_file_list_size = 10 " default value
" set path pattens that should be ignored
let g:mru_ignore_patterns = 'fugitive\|\.git/\|\_^/tmp/' " default value
```

# Usage

mru offers a `Mru` command which will open a MRU buffer to show your
most recently used file list.

Deleting line in the MRU buffer will drop them from the mru list.

mru depends the vim's viminfo or neovim's shada. please confirm your
vim/neovim has been compiled with these feature.

# Story
There is also another plugin called [fzf-filemru](https://github.com/tweekmonster/fzf-filemru)
by [tweekmonster](https://github.com/tweekmonster). But the fzf-filemru
use the **$XDG_CACHE_HOME/fzf_filemru** to store the file list,
the external [filemru.sh](https://github.com/tweekmonster/fzf-filemru/blob/master/bin/filemru.sh) script
to record file list, which is a little heavyweight.

I alsa want to make a PR to tweekmonster. But it will almost be an rewrite PR,
and I do not think tweekmonster will accept.

This is story of mru.

Enjoy yourself :).
