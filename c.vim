" Vim C format file
" This one is for an organizational specific code convention which is probably
" funky for most people to use.
" Language:	C
" Maintainer:	Tucan Sam

let s:keepcpo= &cpo
set cpo&vim

" Make an object for this to pass around common values
let s:formater = {}
"
" The idea:
"   - standard block comments go to column 60
"   - Module and function headers go to column 92
"   - Normal code goes to column 80
"   - Finally inline comments normally go to 70 and wrap
let s:formater.block_com_width = 60
let s:formater.inline_com_width = 72
let s:formater.text_width = 80
let s:formater.header_width = 92

" May need to see about this name...? but it's meant to be autoloaded so should
" be ok..?
" This is meant to be used with formatexpr. The help files of vim say that
" v:count should be the number of lines, but during development it seems like
" Vim just appends all adjacent lines being formated as one concatenated line
" with spaces between each line.
function! Cformat(lnum)
    return s:formater.format(a:lnum)
endfunction

function! s:formater.format(lnum)

    " For now assume the indentation of the line is the indentation to use for
    " all subsequent lines.
    let self.lnum = a:lnum
    let self.indent = indent(self.lnum)

    let self.text = getline(self.lnum)
    let self.width = strdisplaywidth(self.text)

    " Save the styles of the line
    if self.width < self.block_com_width || !has('syntax_items')
        return -1
    endif

    let l:block_com_type = ''
    let l:inline_com_type = ''
    let l:text_type = ''
    let l:header_type = ''
    if self.block_com_width < self.width
        let l:block_com_type = synIDattr(synID(self.lnum, self.block_com_width, 1),
            \ "name")
    endif

    if self.inline_com_width < self.width
        let l:inline_com_type = synIDattr(synID(self.lnum, self.inline_com_width, 1),
            \ "name")
    endif

    if self.text_width < self.width
        " Text can contain special characters like \n or \" so we need to get
        " the stack and see if the text is part of it.
        for l:id in synstack(self.lnum, self.text_width)
            if synIDattr(l:id, "name") =~"String$"
                let l:text_type = synIDattr(l:id, "name")
                break
            endif
        endfor
    endif

    if self.header_width < self.width
        let l:header_type = synIDattr(synID(self.lnum, self.header_width, 1), "name")
    endif

    " If this is a string then let us handle the wrapping nicely
    if l:text_type =~ "String$"
        return self.format_string()
    endif

    " return other than 0 for Vim to default to Cindent
    return -1

    
endfunction

function s:formater.format_string()
    " Strip out any concatenated strings, i.e. '" "'. Make sure to exclude
    " '\" "'.
    let self.text = substitute(self.text, '\([^\\]\)" "', '\1', 'g')

    "Brute force this, by setting the line and getting the style again.
    call setline(self.lnum, self.text);

    " If stripping the '" "' put the string under text width then just go
    " back to default logic.
    if strdisplaywidth(self.text) < self.text_width:
        return -1
    endif

    " Go back to the first space
    let l:i = strridx(self.text, ' ', self.text_width - 2)

    " If there are no spaces in the string just break the string in place
    if l:i <= 0
        let l:i = self.text_width - 2
    endif
        
    " Make sure we are still in the string
    let l:string = 0
    for l:id in synstack(self.lnum, l:i)
        if synIDattr(l:id, "name") =~"String$"
            let l:string = 1
            break
        endif
    endfor

    " If we are still in the string and we aren't already ending at the end
    " of the string signified by a space then a quote
    if l:i && l:string && self.text[l:i + 1] != '"'
        " Now replace the conents
        call setline(self.lnum, self.text[: l:i] . '"')

        " Need to pad up to the indent
        let l:next_indent = cindent(self.lnum + 1)
        call append(self.lnum, repeat(' ', l:next_indent) . '"' . self.text[l:i + 1 :])
        " If we are inserting text then update the cursor.
        if mode() =~# '[iR]' 
            call cursor(self.lnum + 1, col([self.lnum + 1, "$"]))
        else
            " We must be doing paragraph logic so format the next line too
            call self.fomat(self.lnum + 1)
            " I wanted to do this but it was too slow... would like to find a
            " way to pass next line to default formatting.
            "execute 'normal! gqj'
        endif

        return 0
    endif

    " default back to normal format handler
    return -1
endfunction
let &cpo = s:keepcpo
unlet s:keepcpo

