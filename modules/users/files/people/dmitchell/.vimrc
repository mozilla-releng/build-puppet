" ---- General Settings
set nocompatible
set nobackup		" do not keep a backup file, just don't
set showmode
set backspace=indent,eol,start
set history=100
set showcmd
set showmatch
set ruler		" show the cursor position all the time
set number
set incsearch		" do incremental searching
set diffopt=filler,vertical
set timeoutlen=5000	" wait 5s before giving up on a half-typed mapping
set nrformats=hex   " don't increment as octal with leading 0

" indents and tabs
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set shiftround

" cmdline completion similar to shell, and ignore unnecessary files
set wildmode=list:longest
set wildignore=*.pyc,*.o,*.egg-info

" automatically write on :n and :!
set autowrite

" always show status
set laststatus=2

" rgrep on 'K'
set keywordprg=find\ .\ -name\ .git\ -prune\ -o\ -name\ .svn\ -prune\ -o\ -type\ f\ -print0\|xargs\ -0\ grep\ --color

" ---- Key Mappings

" unmap a few things I tend to hit accidentally
" Q usually goes to visual mode
map Q ""
" ^f in command mode usuall opens the command-line editor, which is just in
" the way.  Same for q:
cmap <c-f> <nop>
map q: <Nop>

"folding
set foldmethod=marker

" use v to wrap paragraphs
map v gqap{kk

" meta-X options to do useful things
map <Esc>n :set number!<CR>
map <Esc>p :set paste!<CR>

map <Esc>h :wincmd h<CR>
map <Esc>j :wincmd j<CR>
map <Esc>k :wincmd k<CR>
map <Esc>l :wincmd l<CR>
map <Esc>H :wincmd H<CR>
map <Esc>J :wincmd J<CR>
map <Esc>K :wincmd K<CR>
map <Esc>L :wincmd L<CR>

" H and L usuall go to the top, bottom of the screen.  Let's switch
" tabs instead
map H :tabnext<cr>
map L :tabprev<cr>

" meta-f will fold by syntax, useful for nagivating
" TODO: make this toggle
map <Esc>f :setlocal foldmethod=syntax<CR>
map <Esc>F :setlocal foldmethod=marker<CR>

" Make \\ write everything and run the latest shell command
map <Leader><Leader> :!<up><cr>

" Make ^T in command-line mode delete the last filename segment
cnoremap <C-t> <C-\>e(<SID>RemoveLastPathComponent())<CR>
function! s:RemoveLastPathComponent()
  return substitute(getcmdline(), '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '')
endfunction

" make ^D automatically fill the command line with the current directory
cnoremap <C-d> <C-\>e(<SID>AppendFileDir())<CR>
function! s:AppendFileDir()
  return getcmdline() . " " . expand("%:h:.") . "/"
endfunction

" ---- Filetype-specific stuff
"
" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

" do not "round" things off when shifting C code, as it messes up hanging
" comments
au FileType c setlocal noshiftround

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" makefile stuff
au FileType make setlocal noexpandtab

" autodetect .swg files
au BufRead,BufNewFile *.swg             setfiletype c

" changelog settings
let g:changelog_spacing_errors=1
let g:changelog_new_date_format = "%d  %u\n\t* %c\n\n"
let g:changelog_username = "Dustin J. Mitchell <dustin@cs.uchicago.edu>"
hi link ChangelogError Error

" cindent is terrible on javascript, but smartindent isn't so bad
au filetype javascript setl nocindent smartindent

" ---- color for screen and full-colorxterm
if $TERM == "xterm-256color" || $TERM == "screen"
    set t_Co=256
endif
" ---- Syntax Highlighting

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 1
  set background=dark
  syntax on
endif

if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch

  set background=dark
  hi clear
  if exists("syntax_on")
    syntax reset
  endif
  let g:colors_name = "dustin"
  hi Normal		guifg=cyan			guibg=black
  hi Comment	term=bold		ctermfg=DarkCyan		guifg=#80a0ff
  hi Constant	term=underline	ctermfg=Magenta		guifg=Magenta
  hi Special	term=bold		ctermfg=DarkMagenta	guifg=Red
  hi Identifier term=underline	cterm=bold			ctermfg=Cyan guifg=#40ffff
  hi Statement term=bold		ctermfg=Yellow gui=bold	guifg=#aa4444
  hi PreProc	term=bold	ctermfg=yellow	guifg=#ff80ff
  hi Type	term=underline		ctermfg=LightGreen	guifg=#60ff60 gui=bold
  hi Function	term=bold		ctermfg=White guifg=White
  hi Repeat	term=underline	ctermfg=White		guifg=white
  hi Operator				ctermfg=Red			guifg=Red
  hi Ignore				ctermfg=black		guifg=bg
  hi Error	term=reverse ctermbg=Red ctermfg=White guibg=Red guifg=White
  hi Todo	term=standout ctermbg=Yellow ctermfg=Black guifg=Blue guibg=Yellow
  hi SpecialKey	term=underline	ctermfg=Magenta		guifg=Magenta
  hi NonText	term=underline	ctermfg=Magenta		guifg=Magenta
  hi Underlined	term=underline	ctermfg=white		guifg=white
  
  " Common groups that link to default highlighting.
  " You can specify other highlighting easily.
  hi link String	Constant
  hi link Character	Constant
  hi link Number	Constant
  hi link Boolean	Constant
  hi link Float		Number
  hi link Conditional	Repeat
  hi link Label		Statement
  hi link Keyword	Statement
  hi link Exception	Statement
  hi link Include	PreProc
  hi link Define	PreProc
  hi link Macro		PreProc
  hi link PreCondit	PreProc
  hi link StorageClass	Type
  hi link Structure	Type
  hi link Typedef	Type
  hi link Tag		Special
  hi link SpecialChar	Special
  hi link Delimiter	Special
  hi link SpecialComment Special
  hi link Debug		Special

  " CUSTOMIZATIONS
  " since otherwise pyflakes errors are really hard to read
  hi Spellbad ctermbg=52

  " show the current window with the status line
  hi StatusLine cterm=NONE ctermbg=228 ctermfg=black
  hi StatusLineNC cterm=NONE ctermfg=234 ctermbg=250
endif

" ---- stupid typos

ab funciton function
ab buidlbot buildbot
ab Buidlbot Buildbot

" ---- tabbing between related files

" TODO: make this take a list of transform functions and use
" the first matching function it finds; then Amanda can add
" .swg -> .pod and installcheck/F_O_O -> perl/F/O/O.pm
function! GetAlternateFile()
  if (expand ("%:t") == expand ("%:t:r") . ".c")
    return "%:t:r.h"
  else
    if (expand ("%:t") == expand ("%:t:r") . ".h")
      return "%:t:r.c"
    endif
  endif
endfunction

function! SwitchSourceHeader()
    let l:altfile = GetAlternateFile()
    if l:altfile != ''
        exec "find " . l:altfile
    else
        echo "no alternate"
    endif
endfunction

function! SplitSourceHeader()
    let l:altfile = GetAlternateFile()
    if l:altfile != ''
        exec "vert sfind " . l:altfile
    else
        echo "no alternate"
    endif
endfunction

nmap <tab> :call SwitchSourceHeader()<CR>
nmap <esc><tab> :call SplitSourceHeader()<CR>

" ---- source a project's .vimrc

if $DEV_PROJECT != ""
    if filereadable($DEV_PROJECT . "/.vimrc")
        execute "source " . $DEV_PROJECT . "/.vimrc"
    endif
endif
