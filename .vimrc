"###############################################################################
" vim configuration file
"###############################################################################

set nocompatible

set autoread
set secure
set ttyfast

"#######################################
" files
"#######################################

set viminfo				=
set printheader				=[\ %<%t\ -\ %N\ ]

set swapfile
set directory				=.
">>>set swapsync				=sync
set updatecount				=10
set updatetime				=10

"#######################################
" colors
"#######################################

highlight cursor     guibg=red   ctermbg=red   guifg=black    ctermfg=black
highlight normal     guibg=black ctermbg=black guifg=gray     ctermfg=gray

syntax					on
set background				=light

highlight comment    guibg=black ctermbg=black guifg=darkcyan ctermfg=darkcyan
highlight nontext    guibg=black ctermbg=black guifg=darkcyan ctermfg=darkcyan
highlight specialkey guibg=black ctermbg=black guifg=darkcyan ctermfg=darkcyan

highlight folded     guibg=black ctermbg=black guifg=darkblue ctermfg=darkblue
highlight foldcolumn guibg=black ctermbg=black guifg=darkblue ctermfg=darkblue

"#######################################
" interface
"#######################################

set noautowrite
set noautowriteall
set hidden
set hlsearch
set ignorecase
set incsearch
set noruler
set showcmd
set noshowmode
set smartcase
set novisualbell

set wildmenu
set wildmode				=full
set wildchar				=<tab>

set autoindent
set noexpandtab
set smartindent
set shiftwidth				=8
set tabstop				=8

set scrolljump				=1
set scrolloff				=10
set sidescroll				=10
set sidescrolloff			=10
set history				=10
set undolevels				=1000

set foldenable
set foldcolumn				=1
set foldlevelstart			=99
set foldminlines			=0
set foldmethod				=indent
set foldtext	=v:folddashes.\"\ \".v:foldlevel.\"\ \[\".(v:foldend\ \-\ v:foldstart\ \+\ 1).\"\,\ \".v:foldstart.\"\/\".v:foldend.\"\]\ \"

set whichwrap				=b,s
set backspace				=indent,eol

set list
set listchars				=tab:,.,trail:=,extends:>,precedes:<

set linebreak
set breakat				=\ \\
set showbreak				=+

set textwidth				=0
set formatlistpat			=^\\s*\\w\\+[\\.)]\\s*
set formatoptions			=1cnqrto
set comments				=sr:/*,mb:*,ex:*/,b://,b:###,b:#,b:%,bf:+,bf:-

set highlight				=sr
set laststatus				=2
set statusline				=[\ %<%F%R%M%W%H\ ]\ %=\ [\ %n\ %B\ \|\ %c%V\ %l/%L\ %p%%\ ]

"#######################################
" abbreviations
"#######################################

" date/time stamps
iab @-e 1970-01-01
iab @-d 2038-01-19
iab @-t 2038-01-19T03:14:07-0000
iab @@d <C-R>=strftime("%F")<CR>
iab @@t <C-R>=strftime("%FT%T%z")<CR>

" new items
iab @.n ====-==-==T==:==:==-==== ====-==-== ====-==-==T==:==:==-==== <C-R>=strftime("%F")<CR> ~ __ +VIM+ ~ +VIM+<ESC>0
iab @.s ====-==-==T==:==:==-==== ====-==-== <C-R>=strftime("%FT%T%z")<CR> <C-R>=strftime("%F")<CR> ~ __ +VIM+ ~ +VIM+<ESC>0

"#######################################
" maps
"#######################################

" clean up folding
map z. <ESC>:set foldlevel=1<CR>zv

" jump/edit next token
map  <C-J> <ESC>/+VIM+<CR>c5l
map! <C-J> <C-O>/+VIM+<CR><C-O>c5l

" (re)set folding, columns, pasting and wrapping
map <F1> <ESC>:set foldlevel=1<CR>
map <F2> <ESC>:set columns=81<CR>
map <F3> <ESC>:set invpaste<CR>
map <F4> <ESC>:set invwrap<CR>

" (un)set automatic formatting
map <F5> <ESC>:set formatoptions+=a<CR><ESC>:set expandtab<CR><ESC>:set nolist<CR><ESC>:set textwidth=80<CR>
map <F6> <ESC>:set formatoptions-=a<CR><ESC>:set noexpandtab<CR><ESC>:set list<CR><ESC>:set textwidth=0<CR>

" remove all spaces from the end of all lines
map <F9> <ESC>:%s/[ \t]*$//g<CR>1G

" convert tab-delimited file to properly formatted csv
map <F10> <ESC>:%s/^/\"/g<CR>:%s/\t/\"\,\"/g<CR>:%s/$/\"/g<CR>

"###############################################################################
" end of file
"###############################################################################
