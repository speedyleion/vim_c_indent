" Vim C format file
" This one is for an organizational specific code convention which is probably
" funky for most people to use.
" Language:	C
" Maintainer:	Tucan Sam

let s:keepcpo= &cpo
set cpo&vim

" May need to see about this name...? but it's meant to be autoloaded so should
" be ok..?
" This is meant to be used with formatexpr. The help files of vim say that
" v:count should be the number of lines, but during development it seems like
" Vim just appends all adjacent lines being formated as one concatenated line
" with spaces between each line.
"function! C#Format(lnum, count, char)
function! Cformat()

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
    if width < block_com_width || !has('syntax_items')
        return -1
    endif

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
        " Text can contain special characters like \n or \" so we need to get
        " the stack and see if the text is part of it.
        for id in synstack(v:lnum, text_width)
            if synIDattr(id, "name") =~"String$"
                let text_type = synIDattr(id, "name")
                break
            endif
        endfor
    endif

    if header_width < width
        let header_type = synIDattr(synID(v:lnum, header_width, 1), "name")
    endif

    " If this is a string then let us handle the wrapping nicely
    if text_type =~ "String$"
        " Strip out any concatenated strings, i.e. '" "'. Make sure to exclude
        " '\" "'.
        let text = substitute(text, '\([^\\]\)" "', '\1', 'g')

        " Go back to the first space
        let l:i = strridx(text, ' ', text_width - 2)
            
        " Make sure we are still in the string
        let l:string = 0
        for id in synstack(v:lnum, l:i)
            if synIDattr(id, "name") =~"String$"
                let l:string = 1
                break
            endif
        endfor

        " If we are still in the string and we aren't already ending at the end
        " of the string signified by a space then a quote
        if l:i && l:string && text[l:i + 1] != '"'
            " Now replace the conents
            call setline(v:lnum, text[: l:i] . '"')
            call append(v:lnum, '"' . text[l:i + 1 :])
            return 0
        endif
    endif

    " return other than 0 for Vim to default to Cindent
    return -1

    
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

