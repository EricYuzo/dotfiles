" vim: tw=0 ts=2 sw=2
" Vim color file
" Maintainer:  Eric Yuzo <eyuzo@devsv.com.br>
" Last Change: 2016 May 11


" Remove all existing highlighting
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif


let colors_name = "nel"

hi Normal cterm=none ctermbg=Black ctermfg=White
hi Title  cterm=bold ctermbg=Black ctermfg=White
hi LineNr cterm=none ctermbg=Black ctermfg=DarkGray

hi Search     ctermbg=DarkGreen ctermfg=Black
hi IncSearch  ctermbg=DarkGray  ctermfg=Cyan
hi MatchParen ctermbg=Cyan      ctermfg=DarkGray

hi CursorLine   cterm=none ctermbg=DarkGray
hi CursorColumn cterm=none ctermbg=DarkGray

hi StatusLine cterm=none ctermbg=LightGray ctermfg=Black

hi Error cterm=bold ctermbg=DarkRed ctermfg=White
hi ToDo  cterm=bold ctermbg=Yellow  ctermfg=Black

hi Comment    cterm=none ctermfg=LightCyan
hi Constant   cterm=none ctermfg=Green
hi Number     cterm=none ctermfg=Red
hi Float      cterm=none ctermfg=Brown
hi Boolean    cterm=none ctermfg=DarkMagenta
hi Identifier cterm=none ctermfg=LightBlue
hi Statement  cterm=bold ctermfg=Yellow
hi PreProc    cterm=bold ctermfg=Blue
hi Type       cterm=bold ctermfg=LightGreen
hi Special    cterm=none ctermfg=Cyan

hi TrailSpace ctermbg=DarkRed
match TrailSpace /\s\+$/
