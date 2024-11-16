"https://github.com/alacritty/alacritty/issues/2817
" autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"

set encoding=utf-8
set linebreak
set nowrap
set autoread

"Use Space as Leader key
let mapleader=' '
"ZC closes vim emitting an error code, useful to abort a readline command
"edition
map ZC :cquit<CR>

"No swap or backup
set noswapfile
set hidden
set nobackup
set nowritebackup

"Display relative line number
set number
set number relativenumber

"Indenting
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set autoindent
set smartindent
set cindent

"No automatic commenting on newline
" autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" set background=dark

"Jumping to the last position when reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"Search
set ignorecase
set smartcase
set incsearch
map <Leader>h :nohlsearch<CR>
nnoremap <Esc> :nohlsearch<CR><Esc>

"Hidden characters
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
map <Leader>l :set list!<CR>:set list?<CR> 

"256 colors terminal
set t_Co=256

"Mouse
set mouse=a

"Matching parenthesis
highlight MatchParen ctermbg=black ctermfg=NONE

"Use sudo to write the file
" 1. use sudo non-interactive mode to fail if password is prompted
" 2. try to use run0 if sudo fails (password prompt, not installed...)
"https://github.com/neovim/neovim/issues/1716
cnoreabbrev w!! execute 'silent! write !sudo -n tee % \|\| run0 tee %' <bar> edit!
