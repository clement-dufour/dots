" https://github.com/alacritty/alacritty/issues/2817
"" autocmd VimEnter * <CMD>silent exec "!kill -s SIGWINCH $PPID"

" Jumping to the last position when reopening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" No automatic commenting on newline
"" autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

"" set background=dark

language messages en_US.utf8
set t_Co=256
set encoding=utf-8
set linebreak
set nowrap
set autoread

" Mouse
set mouse=a

" No swap or backup
set noswapfile
set hidden
set nobackup
set nowritebackup

" Display relative line number
set number
set number relativenumber

" Indenting
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set autoindent
set smartindent
set cindent

" Search
set ignorecase
set smartcase
set incsearch

" Matching parenthesis
highlight MatchParen ctermbg=black ctermfg=NONE

" Use SPC as Leader key
let mapleader="\<Space>"
" Quit search highlighting with Esc
nnoremap <ESC> <CMD>nohlsearch<CR><ESC>
" ZC closes nvim emitting an error code, useful to abort a readline command
" edition
nnoremap ZC <CMD>cquit<CR>

" Hidden characters
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
nnoremap <Leader>l <CMD>set list!<CR><CMD>set list?<CR>

" Use sudo to write the file
"  1. use sudo non-interactive mode to fail if password is prompted
"  2. try to use run0 if sudo fails (password prompt, not installed...)
" https://github.com/neovim/neovim/issues/1716
"" cnoreabbrev w!! execute 'silent! write !sudo -n tee % \|\| run0 tee %' <BAR> edit!
cnoreabbrev w!! execute 'silent! write !sudo -n tee %' <BAR> edit!
