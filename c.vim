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

    
    if !has('syntax_items')
        return -1
    endif

    " The idea:
    "   - standard block comments go to column 60
    "   - Module and function headers go to column 92
    "   - Normal code goes to column 80
    "   - Finally inline comments normally go to 70 and wrap
    let block_com_width = 60
    let inline_com_width = 72
    let text_width = 80
    let header_width = 92

    " For now assume the indentation of the line is the indentation to use for
    " all subsequent lines.
    let indent = indent(v:lnum)
    let text = getline(v:lnum)
    let width = strdisplaywidth(text)

    " Save the styles of the line
    let block_com_type = ''
    let inline_com_type = ''
    let text_type = ''
    let header_type = ''
    if block_com_width < width
        let block_com_type = synIDattr(synID(v:lnum, block_com_width, 1),
            \ "name")
    endif

    if inline_com_width < width
        let inline_com_type = synIDattr(synID(v:lnum, inline_com_width, 1),
            \ "name")
    endif

    if text_width < width
        let text_type = synIDattr(synID(v:lnum, text_width, 1), "name")
    endif

    if header_width < width
        let header_type = synIDattr(synID(v:lnum, header_width, 1), "name")
    endif

    " If this is a string then let us handle the wrapping nicely
    if text_type =~ "String$"
        " Go back to the first space and append a quote
        " HACK FOR TESTING JUST CUT STRING AND APPEND QUOTE
        
        " Now replace the conents
        call setline(v:lnum, text[:text_width] . '"')
        call append(v:lnum, '"' . text[text_width + 1:])
        return 0
    endif

    " return other than 0 for Vim to default to Cindent
    return -1

    
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

