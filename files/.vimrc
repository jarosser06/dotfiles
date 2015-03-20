" bring in the bundles for mac and windows
set rtp+=vimfiles/vundle.git/
set rtp+=.vim/vundle.git/
call vundle#rc()

runtime! common_confi*.vim
runtime! custom_confi*.vim

" for git, add spell checking and automatic wrapping at 72 columns
autocmd Filetype gitcommit setlocal spell textwidth=72
