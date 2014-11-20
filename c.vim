" Vim C format file
" This one is for an organizational specific code convention which is probably
" funky for most people to use.
" Language:	C
" Maintainer:	Tucan Sam

let s:keepcpo= &cpo
set cpo&vim

" May need to see about this name...? but it's meant to be autoloaded so should
" be ok..?
"function! C#Format(lnum, count, char)
function! Cformat()

    " The idea:
    "   - standard block comments go to column 60
    "   - Module and function headers go to column 92
    "   - Normal code goes to column 80
    "   - Finally inline comments normally go to 70 and wrap
    let l:header_width = 92
    let l:block_com_width = 60
    let l:text_width = 80
    let l:inline_com_width = 72

    " For now assume the indentation of the line is the indentation to use for
    " all subsequent lines.
    let indent = indent(v:lnum)
    let text = getline(v:lnum)
    echom "This is the indent"
    echom indent

    " return other than 0 for Vim to default to Cindent
    return -1

    
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

