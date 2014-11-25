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
function! Cformat(lnum)

    " For now assume the indentation of the line is the indentation to use for
    " all subsequent lines.
    let l:indent = indent(a:lnum)

    " The idea:
    "   - standard block comments go to column 60
    "   - Module and function headers go to column 92
    "   - Normal code goes to column 80
    "   - Finally inline comments normally go to 70 and wrap
    let l:block_com_width = 60
    let l:inline_com_width = 72
    let l:text_width = 80
    let l:header_width = 92

    let l:text = getline(a:lnum)
    echom l:text
    echom l:indent
    let l:width = strdisplaywidth(l:text)

    " Save the styles of the line
    if l:width < l:block_com_width || !has('syntax_items')
        return -1
    endif

    let block_com_type = ''
    let inline_com_type = ''
    let l:text_type = ''
    let header_type = ''
    if l:block_com_width < l:width
        let block_com_type = synIDattr(synID(a:lnum, l:block_com_width, 1),
            \ "name")
    endif

    if l:inline_com_width < l:width
        let inline_com_type = synIDattr(synID(a:lnum, l:inline_com_width, 1),
            \ "name")
    endif

    if l:text_width < l:width
        " Text can contain special characters like \n or \" so we need to get
        " the stack and see if the text is part of it.
        for l:id in synstack(a:lnum, l:text_width)
            if synIDattr(id, "name") =~"String$"
                let l:text_type = synIDattr(l:id, "name")
                break
            endif
        endfor
    endif

    if l:header_width < l:width
        let header_type = synIDattr(synID(a:lnum, l:header_width, 1), "name")
    endif

    " If this is a string then let us handle the wrapping nicely
    if l:text_type =~ "String$"
        " Strip out any concatenated strings, i.e. '" "'. Make sure to exclude
        " '\" "'.
        let l:text = substitute(l:text, '\([^\\]\)" "', '\1', 'g')

        "Brute force this, by setting the line and getting the style again.
        call setline(a:lnum, l:text);

        " If stripping the '" "' put the string under text width then just go
        " back to default logic.
        if strdisplaywidth(l:text) < l:text_width:
            return -1
        endif

        " Go back to the first space
        let l:i = strridx(l:text, ' ', l:text_width - 2)

        " If there are no spaces in the string just break the string in place
        if l:i <= 0
            let l:i = l:text_width - 2
        endif
            
        " Make sure we are still in the string
        let l:string = 0
        for l:id in synstack(a:lnum, l:i)
            if synIDattr(l:id, "name") =~"String$"
                let l:string = 1
                break
            endif
        endfor

        " If we are still in the string and we aren't already ending at the end
        " of the string signified by a space then a quote
        if l:i && l:string && l:text[l:i + 1] != '"'
            " Now replace the conents
            call setline(a:lnum, l:text[: l:i] . '"')
            call append(a:lnum, '"' . l:text[l:i + 1 :])
            echom cindent(a:lnum + 1 )
            cursor(a:lnum + 1, $)
            echom getcurpos()
            call Cformat(a:lnum + 1)
            " I wanted to do this but it was too slow... would like to find a
            " way to pass next line to default formatting.
            "execute 'normal! gqj'

            " Need to reset the cursor
            return 0
        endif
    endif

    " return other than 0 for Vim to default to Cindent
    echom 'returning to default'
    return -1

    
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

