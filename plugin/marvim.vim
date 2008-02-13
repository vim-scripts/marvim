" MARVIM - MAcro Repository for VIM <marvim.vim>
" Macro and Template saving, lookup and launch script for VIM
" Pronounced Marvin - The paranoid android in Hitchhikers Guide to the Galaxy 
"
" Script Info and Documentation  {{{
"=============================================================================
"    Copyright: Copyright (C) 2007 & 2008 Chamindra de Silva 
"      License: GPL v2
" Name Of File: marvim.vim
"  Description: Macro Repository Vim Plugin
"   Maintainer: Chamindra de Silva <chamindra@gmail.com> 
"          URL: http://chamindra.googlepages.com/marvim 
"  Last Change: Feb 9, 2008
"      Version: 0.1 Alpha
"
"        Usage: 
"        
" Hotkeys
" --------
" <F2>        - SAVE MACRO by name to a macro directory in normal mode
" Visual <F2> - SAVE a TEMPLATE by name to the macro directory in visual mode
" <F3>        - search and EXECUTE a MACRO or insert TEMPLATE in the macro directory
" Visual <F3> - in visual mode REPLAYS last loaded MACRO for each line
" . (dot)     - REPLAY last MACRO
"=============================================================================
" }}}
"
" Features
" - Platform independant script (almost ;-)
" - recording of vim version with macro 
" - redefinition of macro_home and macro_register
"
" Todo
" - check vim version number when running macro
" - get over personal vim customizations on macro replay
" - make macro_home and macro_register global/buffer variables

let s:macro_home = $HOME."/.marvim/"
let s:macro_register = 'c'

let s:vim_ver = strpart(v:version,0,1) " get the major vim version number

let s:ext = '.mv'.s:vim_ver  " specify macro extension by vim version number
let s:text = '.tpl' " template extension

" ==HOTKEYS==
" IMPORTANT that there are no spaces after the remap lines
nnoremap <F2> :call Macro_input_save()<CR>
vnoremap <F2> :<C-U>call Template_input_save()<CR>
nnoremap <F3> :call Macro_input_find()<CR>
exec 'vnoremap <F3> :norm@'.s:macro_register.'<CR>'


"vnoremap <F3> :<C-U>call Test_visual()<CR>

function! Test_visual()

    execute ":'<,'>s/func/FUNC/g"
    echo 'hello there '

endfunction


" template save
function! Template_input_save()

    " yank the visual block into the default register
    " if previous command was not visual this is ignored
    " allowing for other forms of yanking
    execute 'normal! `<v`>y<CR>'  

    let l:listtmp = split(@@,'\n') " get default yank buffer
    let l:template_name = input('Enter Template Name : ') 
    call writefile(l:listtmp, s:macro_home.l:template_name.s:text)
    "let l:text = getreg(s:macro_register)
    "call setreg(s:macro_register, 'a'.l:text)

endfunction


" hotkey mapping dynamic input function for Macro_save
function! Macro_input_save()

    let l:macro_name = input('Enter Macro Name : ') 
    call Macro_save(l:macro_name)

endfunction

" The macro save function
function! Macro_save(macro_name)

    "let l:listtmp = [@c] " get the macro from register c
    let l:listtmp = [getreg(s:macro_register)]
    call writefile(l:listtmp, s:macro_home.a:macro_name.s:ext, 'b')

endfunction

" Run the macro file
" @param macro_file - full path to the macro file
function! Macro_run(macro_file)

    " find if it is a template or a macro
    let l:t = split(a:macro_file, '\.')
    let s:macro_type = l:t[-1] " get the extension

    if s:macro_type == 'tpl'  " read template

        silent execute 'read '.a:macro_file
        "echo 'Read Template '.a:macro_file
    
"    elseif s:macro_type == 'sh' " a filter
"        
"        silent execute  

    else  " a vim macro
        " execute 'so! '.s:macro_home.a:macro_name.s:ext
        
        " read the macro file into the register and run it
        let l:macro_content = readfile(a:macro_file,'b')
        call setreg(s:macro_register,l:macro_content[0]) 
        silent execute 'normal @'.s:macro_register
        "echo 'Ran Macro '.a:macro_file

    endif

endfunction

" Macro find
function! Macro_input_find()

   let l:search_string = input('Macro Search : ')

   let l:search_list = glob(s:macro_home.'*'.l:search_string.'*') 

   " split globbed files into a list
   let l:macro_list = split(l:search_list)

   " filter each item in the list
   let l:item_count = 0
   for l:item in l:macro_list

        let l:item_count = l:item_count + 1

        " get the filename
        let l:dir_split = split (l:item, '/') " TODO: windows path seperator
        let l:filename = l:dir_split[-1]

        " remove trailing extension
        let l:name_split = split (l:filename, '\.') " TODO: can break on multiple .

        " display each option in a list with the type of macro
        echo l:item_count.'. '.l:name_split[0].' ('.l:name_split[-1].')' 

   endfor 

   if l:item_count == 0

       echo "No Matches Found"

   elseif l:item_count == 1 " if exact match is found execute it

       call Macro_run(l:macro_list[0])
       echo "Exact Match Found and Run"

   else " otherwise list possibilities and let user choose

       let l:item_count = input('Select Macro to Run? (Default none) :')

       if l:item_count != '' 
           call Macro_run(l:macro_list[l:item_count - 1])
       endif
   endif

endfunction
