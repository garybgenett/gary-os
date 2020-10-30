"###############################################################################
" vim configuration file
"###############################################################################

set nocompatible

set autoread
set secure
set ttyfast

let loaded_matchparen			=1

"#######################################
" files
"#######################################

set viminfo				=
set printheader				=[\ %<%t\ -\ %N\ ]

set noswapfile
set directory				=.
set swapsync				=sync
set updatecount				=10
set updatetime				=10

"#######################################
" colors
"#######################################

highlight cursor     guibg=red   ctermbg=red  guifg=black    ctermfg=black
highlight normal     guibg=black ctermbg=none guifg=gray     ctermfg=gray

filetype				on
syntax					on
set background				=light
set guioptions				=aciA

highlight comment    guibg=black ctermbg=none guifg=darkcyan ctermfg=darkcyan
highlight nontext    guibg=black ctermbg=none guifg=darkcyan ctermfg=darkcyan
highlight specialkey guibg=black ctermbg=none guifg=darkcyan ctermfg=darkcyan

highlight folded     guibg=black ctermbg=none guifg=darkblue ctermfg=darkblue
highlight foldcolumn guibg=black ctermbg=none guifg=darkblue ctermfg=darkblue

"#######################################
" interface
"#######################################

set noautowrite
set noautowriteall
set hidden
set hlsearch
set ignorecase
set incsearch
set modeline
set noruler
set showcmd
set noshowmode
set smartcase
set nospell
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
set history				=100
set undolevels				=1000

set foldenable
set foldcolumn				=1
set foldlevelstart			=99
set foldminlines			=0
set foldmethod				=indent
set foldtext				=v:folddashes.\"\ \".v:foldlevel.\"\ \[\".(v:foldend\ \-\ v:foldstart\ \+\ 1).\"\,\ \".v:foldstart.\"\-\".v:foldend.\"\]\ \"

set whichwrap				=b,s
set backspace				=indent,eol

set list
set listchars				=tab:,.,trail:=,extends:>,precedes:<

set linebreak
set breakat				=\ \\
set showbreak				=+

set textwidth				=0
set formatlistpat			=^\\s*\\w\\+[\\.)]\\s*
set formatoptions			=12cjnoqrt
set comments				=sr:/*,mb:*,ex:*/,b://,b:###,b:#,b:%,bf:+,bf:-

set highlight				=sr
set laststatus				=2
set statusline				=[\ %<%F%R%M%W%H\ ]%y\ %=\ [\ %n\ \|\ %b\ 0x%B\ \|\ %c,%v\ %l/%L\ %p%%\ ]

"#######################################
" tabline
"#######################################

set showtabline				=2
set tabline				=%!CustomTabLine()

function CustomTabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		let n = i + 1
		let buflist = tabpagebuflist(n)
		let winnr = tabpagewinnr(n) - 1
		let s .= '%' . n . 'T'
		let s .= '[ '
		let s .= buflist[winnr] . (n == tabpagenr() ? '*' : '')
		let s .= ' '
		let s .= bufname(buflist[winnr]) . (getbufvar(n, '&modified') ? ',+' : '')
		let s .= ' ]'
	endfor
	let s .= '%='
	let s .= '%999X[X]%X'
	return s
endfunction

"#######################################
" abbreviations
"#######################################

" date/time stamps
iab @-e 1970-01-01
iab @-d 2038-01-19
iab @-t 2038-01-19T03:14:07-0000
iab @@d <C-R>=strftime("%F")<CR>
iab @@t <C-R>=strftime("%FT%T%z")<CR>
iab @@a <C-R>=strftime("%F %T")<CR>
iab @@j <C-R>=strftime("%F, %a")<CR>

" new items
iab @.n ====-==-==T==:==:==-==== ====-==-== ====-==-==T==:==:==-==== <C-R>=strftime("%F")<CR> ~ __ +VIM+ ~ +VIM+<ESC>0
iab @.s ====-==-==T==:==:==-==== ====-==-== <C-R>=strftime("%FT%T%z")<CR> <C-R>=strftime("%F")<CR> ~ __ +VIM+ ~ +VIM+<ESC>0

"#######################################
" maps
"#######################################

" non-ascii characters
map na <ESC>/[^	 A-Za-z0-9`~!@#$%^&*()_=+\[{\]}\\\|;:'",<.>/?-]<CR>

" clean up folding
map z. <ESC>:set foldlevel=0<CR>zv
map z1 <ESC>:set foldlevel=0<CR>/\[personal\]<CR>
map z2 <ESC>:set foldlevel=0<CR>/\[work\]<CR>

" jump/edit next token
map  <C-J> <ESC>/+VIM+<CR>c5l
map! <C-J> <C-O>/+VIM+<CR><C-O>c5l

" turn swapfile off
map <F3> <ESC>:set swapfile<CR>

" convert tab-delimited file to properly formatted csv
map <F4> <ESC>:%s/^/\"/g<CR>:%s/\t/\"\,\"/g<CR>:%s/$/\"/g<CR>

" (re)set folding, columns, pasting and wrapping
map <F5> <ESC>:set foldlevel=1<CR>
map <F6> <ESC>:set foldcolumn=0<CR>:set columns=80<CR>:set showbreak=<CR>
map <F7> <ESC>:set invpaste<CR>
map <F8> <ESC>:set invwrap<CR>

" remove all spaces from the end of all lines
map <F9> <ESC>:%s/[ \t]*$//g<CR>1G

" (un)set automatic formatting
map <F10> <ESC>:set formatoptions+=a<CR><ESC>:set   spell<CR><ESC>:set   expandtab<CR><ESC>:set shiftwidth=2<CR><ESC>:set tabstop=2<CR><ESC>:set textwidth=80<CR>
map <F11> <ESC>:set formatoptions-=a<CR><ESC>:set   spell<CR><ESC>:set   expandtab<CR><ESC>:set shiftwidth=2<CR><ESC>:set tabstop=2<CR><ESC>:set textwidth=0 <CR>
map <F12> <ESC>:set formatoptions-=a<CR><ESC>:set nospell<CR><ESC>:set noexpandtab<CR><ESC>:set shiftwidth=8<CR><ESC>:set tabstop=8<CR><ESC>:set textwidth=0 <CR>

"###############################################################################
" end of file
"###############################################################################
