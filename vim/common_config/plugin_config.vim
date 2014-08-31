" Plugins are managed by Vundle. Once VIM is open run :BundleInstall to
" install plugins.

" Plugins requiring no additional configuration or keymaps
  Bundle "https://github.com/oscarh/vimerl.git"
  Bundle "https://github.com/tpope/vim-git.git"
  Bundle "https://github.com/harleypig/vcscommand.vim.git"
  Bundle "https://github.com/altercation/vim-colors-solarized.git"
  Bundle "https://github.com/tpope/vim-cucumber.git"
  Bundle "https://github.com/tpope/vim-endwise.git"
  Bundle "https://github.com/tpope/vim-fugitive.git"
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
" Bundle "https://github.com/wavded/vim-stylus.git"
  Bundle "https://github.com/tpope/vim-abolish.git"
  Bundle "https://github.com/christoomey/vim-tmux-navigator.git"

" Dash Searching"
  Bundle "https://github.com/rizzatti/funcoo.vim.git"
  Bundle "https://github.com/rizzatti/dash.vim.git"
    nmap <Leader>qs <Plug>DashSearch
    nmap <Leader>qa <Plug>DashGlobalSearch


" CtrlP - with FuzzyFinder compatible keymaps
  Bundle "https://github.com/kien/ctrlp.vim.git"
    nnoremap <Leader>b :<C-U>CtrlPBuffer<CR>
    nnoremap <Leader>t :<C-U>CtrlP<CR>
    nnoremap <Leader>T :<C-U>CtrlPTag<CR>
    let g:ctrlp_prompt_mappings = {
        \ 'PrtSelectMove("j")':   ['<down>'],
        \ 'PrtSelectMove("k")':   ['<up>'],
        \ 'AcceptSelection("h")': ['<c-j>'],
        \ 'AcceptSelection("v")': ['<c-k>', '<RightMouse>'],
        \ }
    " respect the .gitignore
    let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others']

" Compile and deploy Arduino (*.pde) sketches directly from Vim
  Bundle "https://github.com/smerrill/vim-arduino.git"
    au BufNewFile,BufRead *.pde set filetype=arduino
    au BufNewFile,BufRead *.ino set filetype=arduino

" Go
  Bundle "https://github.com/fatih/vim-go.git"
    au BufNewFile,BufRead *.go set filetype=go

" Slim
  Bundle "https://github.com/slim-template/vim-slim.git"
    au BufNewFile,BufRead *.slim set filetype=slim

" Less
  Bundle "https://github.com/groenewege/vim-less.git"
    au BufNewFile,BufRead *.less set filetype=less

" Handlebars, Mustache, and Friends
  Bundle "https://github.com/mustache/vim-mustache-handlebars.git"
  au  BufNewFile,BufRead *.mustache,*.handlebars,*.hbs,*.hogan,*.hulk,*.hjs set filetype=html syntax=mustache | runtime! ftplugin/mustache.vim ftplugin/mustache*.vim ftplugin/mustache/*.vim

" Stylus
  Bundle "https://github.com/wavded/vim-stylus.git"
    au BufNewFile,BufRead *.styl set filetype=stylus

" Coffee script
  Bundle "https://github.com/kchmck/vim-coffee-script.git"
    au BufNewFile,BufRead *.coffee set filetype=coffee


" ACK
" Bundle "https://github.com/mileszs/ack.vim.git"
"   nmap g/ :Ack!<space>
"   nmap g* :Ack! -w <C-R><C-W><space>
"   nmap ga :AckAdd!<space>
"   nmap gn :cnext<CR>
"   nmap gp :cprev<CR>
"   nmap gq :ccl<CR>
"   nmap gl :cwindow<CR>

" AG aka The Silver Searcher
  Bundle 'https://github.com/rking/ag.vim.git'
    nmap g/ :Ag!<space>
    nmap g* :Ag! -w <C-R><C-W><space>
    nmap ga :AgAdd!<space>
    nmap gn :cnext<CR>
    nmap gp :cprev<CR>
    nmap gq :ccl<CR>
    nmap gl :cwindow<CR>


" Tagbar for navigation by tags using CTags
  Bundle "https://github.com/majutsushi/tagbar.git"
    let g:tagbar_autofocus = 1
    map <Leader>rt :!ctags --extra=+f -R *<CR><CR>
    map <Leader>. :TagbarToggle<CR>


" Markdown syntax highlighting
  Bundle "https://github.com/tpope/vim-markdown.git"
    augroup mkd
      autocmd BufNewFile,BufRead *.mkd      set ai formatoptions=tcroqn2 comments=n:> filetype=markdown
      autocmd BufNewFile,BufRead *.md       set ai formatoptions=tcroqn2 comments=n:> filetype=markdown
      autocmd BufNewFile,BufRead *.markdown set ai formatoptions=tcroqn2 comments=n:> filetype=markdown
    augroup END


" Markdown preview to quickly preview markdown files
  Bundle "https://github.com/maba/vim-markdown-preview.git"
  map <buffer> <Leader>mp :Mm<CR>


" NERDTree for project drawer
  Bundle "https://github.com/scrooloose/nerdtree.git"
    let NERDTreeHijackNetrw = 0

    nmap gt :NERDTreeToggle<CR>
    nmap g :NERDTree \| NERDTreeToggle \| NERDTreeFind<CR>


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

" ZoomWin to fullscreen a particular buffer without losing others
  Bundle "https://github.com/vim-scripts/ZoomWin.git"
    map <Leader>z :ZoomWin<CR>


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


" gist-vim for quickly creating gists
  Bundle "https://github.com/mattn/webapi-vim.git"
  Bundle "https://github.com/mattn/gist-vim.git"
    if has("mac")
      let g:gist_clip_command = 'pbcopy'
    elseif has("unix")
      let g:gist_clip_command = 'xclip -selection clipboard'
    endif

    let g:gist_detect_filetype = 1
    let g:gist_open_browser_after_post = 1


" gundo for awesome undo tree visualization
  Bundle "https://github.com/sjl/gundo.vim.git"
    map <Leader>h :GundoToggle<CR>


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
  Bundle "https://github.com/amdt/vim-niji.git"
  autocmd BufNewFile,BufRead *.clj set filetype=clojure
  autocmd BufNewFile,BufRead *.edn set filetype=clojure

  let g:paredit_leader= '\'


" Jade Highlighting"
  Bundle "https://github.com/digitaltoad/vim-jade.git"
  autocmd BufNewFile,BufRead *.jade set filetype=jade

" Scala Highlighting"
  Bundle "https://github.com/derekwyatt/vim-scala.git"
  autocmd BufNewFile,BufRead *.scala set filetype=scala

" Elixir plugin
  Bundle "https://github.com/elixir-lang/vim-elixir.git"
    au BufNewFile,BufRead *.ex set filetype=elixir
    au BufNewFile,BufRead *.exs set filetype=elixir
