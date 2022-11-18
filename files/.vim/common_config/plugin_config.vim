" Plugins are managed by Vundle. Once VIM is open run :BundleInstall to
" install plugins.

" JSON
  Bundle "https://github.com/elzr/vim-json"

" Linting
  Plugin 'dense-analysis/ale'
  let g:ale_linters = {'python': ['flake8', 'pylint']}
  let g:ale_lint_on_text_changed = 'never'
  let g:ale_lint_on_insert_leave = 0
  let g:ale_lint_on_enter = 0

" Plugins requiring no additional configuration or keymaps
  Bundle "https://github.com/oscarh/vimerl.git"
  Bundle "https://github.com/tpope/vim-git.git"
  Bundle "https://github.com/harleypig/vcscommand.vim.git"
  Bundle "https://github.com/altercation/vim-colors-solarized.git"
  Bundle "https://github.com/tpope/vim-endwise.git"
  Bundle "https://github.com/tpope/vim-haml.git"
  Bundle "https://github.com/pangloss/vim-javascript.git"
  Bundle "https://github.com/vim-scripts/L9.git"
  Bundle "https://github.com/tpope/vim-rake.git"
  Bundle "https://github.com/vim-ruby/vim-ruby.git"
  Bundle "https://github.com/ervandew/supertab.git"
  Bundle "https://github.com/tomtom/tcomment_vim.git"
  Bundle "https://github.com/michaeljsmith/vim-indent-object.git"
  Bundle "https://github.com/vim-scripts/matchit.zip"
  Bundle "https://github.com/kana/vim-textobj-user.git"
  Bundle "https://github.com/nelstrom/vim-textobj-rubyblock.git"
  Bundle "https://github.com/tpope/vim-repeat.git"
  Bundle "https://github.com/vim-scripts/ruby-matchit.git"
  Bundle "https://github.com/wgibbs/vim-irblack.git"
  Bundle "https://github.com/tpope/vim-abolish.git"
  Bundle "https://github.com/christoomey/vim-tmux-navigator.git"
  Bundle "https://github.com/bling/vim-airline.git"

" Typescript
  Bundle "https://github.com/leafgarland/typescript-vim.git"

" Go
  Bundle "https://github.com/fatih/vim-go.git"
    au BufNewFile,BufRead *.go set filetype=go

    let g:go_list_type = "quickfix"

" Tagbar for navigation by tags using CTags
  Bundle "https://github.com/majutsushi/tagbar.git"
    let g:tagbar_autofocus = 1
    map <Leader>rt :!ctags --extra=+f -R *<CR><CR>
    map <Leader>. :TagbarToggle<CR>


" NERDTree for project drawer
  Bundle "https://github.com/scrooloose/nerdtree.git"
    let NERDTreeHijackNetrw = 0

    nmap gt :NERDTreeToggle<CR>
    nmap g :NERDTree \| NERDTreeToggle \| NERDTreeFind<CR>

    " Close Nerdtree when last window
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
      \ quit | endif


" Tabular for aligning text
  Bundle "https://github.com/godlygeek/tabular.git"
    function! CustomTabularPatterns()
      if exists('g:tabular_loaded')
        AddTabularPattern! symbols         / :/l0
        AddTabularPattern! hash            /^[^>]*\zs=>/
        AddTabularPattern! chunks          / \S\+/l0
        AddTabularPattern! assignment      / = /l0
        AddTabularPattern! comma           /^[^,]*,/l1
        AddTabularPattern! colon           /:\zs /l0
        AddTabularPattern! options_hashes  /:\w\+ =>/
      endif
    endfunction

    autocmd VimEnter * call CustomTabularPatterns()

    " shortcut to align text with Tabular
    map <Leader>a :Tabularize<space>

" Unimpaired for keymaps for quicky manipulating lines and files
  Bundle "https://github.com/tpope/vim-unimpaired.git"
    " Bubble single lines
    nmap <C-Up> [e
    nmap <C-Down> ]e

    " Bubble multiple lines
    vmap <C-Up> [egv
    vmap <C-Down> ]egv


" Syntastic for catching syntax errors on save
  Bundle "https://github.com/scrooloose/syntastic.git"
    let g:syntastic_enable_signs=1
    let g:syntastic_quiet_messages = {'level': 'warning'}
    " syntastic is too slow for haml and sass
    let g:syntastic_mode_map = { 'mode': 'active',
                               \ 'active_filetypes': [],
                               \ 'passive_filetypes': ['haml','scss','sass'] }
    let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']


" rails.vim, nuff' said
  Bundle "https://github.com/tpope/vim-rails.git"
    map <Leader>oc :Rcontroller<Space>
    map <Leader>ov :Rview<Space>
    map <Leader>om :Rmodel<Space>
    map <Leader>oh :Rhelper<Space>
    map <Leader>oj :Rjavascript<Space>
    map <Leader>os :Rstylesheet<Space>
    map <Leader>oi :Rintegration<Space>


" surround for adding surround 'physics'
  Bundle "https://github.com/tpope/vim-surround.git"
    " # to surround with ruby string interpolation
    let g:surround_35 = "#{\r}"
    " - to surround with no-output erb tag
    let g:surround_45 = "<% \r %>"
    " = to surround with output erb tag
    let g:surround_61 = "<%= \r %>"


" Clojure Highlighting"
  Bundle "https://github.com/tpope/vim-fireplace.git"
  Bundle "https://github.com/tpope/vim-classpath.git"
  Bundle "https://github.com/guns/vim-clojure-static.git"
  Bundle "https://github.com/vim-scripts/paredit.vim"
  autocmd BufNewFile,BufRead *.clj set filetype=clojure
  autocmd BufNewFile,BufRead *.edn set filetype=clojure

  let g:paredit_leader= '\'

" Scala Highlighting"
  Bundle "https://github.com/derekwyatt/vim-scala.git"
  autocmd BufNewFile,BufRead *.scala set filetype=scala
