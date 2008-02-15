" MARVIM - MAcro Repository for VIM <marvim.vim>
" Macro and Template saving, lookup and launch script for VIM
" Pronounced Marvinn - The paranoid android in Hitchhikers Guide to the Galaxy 
"
" Script Info and Documentation  {{{
"=============================================================================
"    Copyright: Copyright (C) 2007 & 2008 Chamindra de Silva 
"      License: GPL v2
" Name Of File: marvim.vim
"  Description: MAcro Repository Vim Plugin
"   Maintainer: Chamindra de Silva <chamindra@gmail.com> 
"          URL: http://chamindra.googlepages.com/marvim 
"  Last Change: 2008 Feb 15
"      Version: 0.2 Alpha
"
"        Usage: 
"
" Installation
" ------------
" 
" o Download Marvim to your VIM plugin ($VIMRUNTIME/plugin) directory 
"   or source it explicity. Below is an example if you place it in 
"   the home directory
"
"   source $HOME/marvim.vim 
"
" o Start vim and this will automatically create the base marvim macro 
"   repository in your home directory. Based on the OS it will be 
"   located as follows:
"
"   UNIX      ~/.marvim  
"   WINDOWS   C:\Document and Settings\Username\marvim 
"
" o (optional) Copy predefined macro/template directories into the base 
"   marvin macro directory. Marvim uses recursive directory search so 
"   you can nest the directories as you wish.
"
" o (optional) if you want to change the default hotkeys see below
"        
" Default Hotkeys
" ---------------
"   <F2>        - Find and execute a macro or insert template from repository
"   Visual <F2> - Replays last macro for each line selected
"   <F3>        - Save default macro register by name to the macro repository 
"   Visual <F3> - Save selection as template by name to the macro repository 
"
" Changing the default hotkeys and register
" -----------------------------------------
" Place the following lines in your vimrc before the location you source
" the marvim.vim script. Below is an example:
"
"   let marvim_find_key = '<Space>'
"   let marvim_store_key = 'ms'
"   let marvim_register = 'c'
"   source $HOME/marvim.vim   " omit if marvim.vim is in the plugin dir
"
" Tips
" ----
"  o <Space> can be very effective as the macro find key
"  o use a naming convention for your macros to make it easy to find. e.g.:
"
"    php-if-block
"    php-strip-tags
"    php-mysql-select-block
"    php-mysql-update-block
"
" Change Log
" ----------
" v0.2
" - Made script windows compatible
" - Makes the macro home directory if it does not exist
" - Recursively looks up base repository subdirectories for macros
" - Creates a macro menu for the GUI versions
" - Changed defauly macro input register to q
" - Made it easy to define configuration details in vimrc
" - Abstracted hotkeys so that they can be defined in the vimrc easily
" - Fixed the breaking on spaces in directory paths
" - Changed template extension to mvt for ease
" - Changed naming conventions to avoid namespace conflict
" v0.1
" - Platform independant script (almost ;-)
" - recording of vim version with macro 
" - redefinition of macro_home and macro_register
"
" Todo
" - check vim version number when running macro
"
"=============================================================================
" }}}

" check if script is loaded already or if the user does not want it loaded
if exists("loaded_marvim")
	finish
endif
let loaded_marvim = 1

" define hotkeys if they have not been defined in the vimrc
if !exists('marvim_register')
    let g:marvim_register = 'q'  
endif

if !exists('marvim_find_key')
    let g:marvim_find_key = '<F2>'
endif

if !exists('marvim_store_key')
    let g:marvim_store_key = '<F3>'
endif

" Define all mappings to functions provided keys are available
" Define all mappings to functions provided keys are available
"
" if mapcheck(g:marvim_store_key) == "" && mapcheck(g:marvim_find_key) == "" 
    exec 'nnoremap '.g:marvim_store_key.' :call Marvim_macro_store()<CR>'
    "exec 'nnoremap '.g:marvim_store_key.' :call Marvim_template_store()<CR>'
    exec 'vnoremap '.g:marvim_store_key.' y:call Marvim_template_store()<CR>'
    exec 'nnoremap '.g:marvim_find_key.' :call Marvim_search()<CR>'
    exec 'vnoremap '.g:marvim_find_key.' :norm@'.g:marvim_register.'<CR>' 
" endif

    "exec 'vnoremap '.g:marvim_store_key.' :<C-U>call Marvim_visual_template_store()<CR>'

if has('menu')
    menu &Macro.&Find :call Marvim_search()<CR>
    nmenu &Macro.&Store\ Macro :call Marvim_macro_store()<CR>
    vmenu &Macro.&Store\ Template y:call Marvim_template_store()<CR>
    nmenu &Macro.&Store\ Template :call Marvim_template_store()<CR>
endif

" OS Specific configuration 
if has('win16') || has('win32') || has ('win95') || has('win64')
    let s:macro_home = $HOME.'\marvim\' " under your documents and settings 
    let s:path_seperator = '\'
else " assume UNIX based
    let s:macro_home = $HOME."/.marvim/"
    let s:path_seperator = '/'
endif

" TODO or reset the home directory if it has been defined by the user
"if exists('marvim_store')
"    if g:marvim_store[-1:] != s:path_seperator
"        let s:macro_home = g:marvim_store.s:path_seperator
"    else
"        let s:macro_home = g:marvim_store
"    endif
"endif

" create the repository directory if it does not exist
if !isdirectory(s:macro_home)

    let s:tmp = mkdir(s:macro_home)
    " let s:tmp = system("mkdir \"".s:macro_home."\"")  " hard way for windows
endif

let s:vim_ver = strpart(v:version,0,1) " get the major vim version number
let s:ext = '.mv'.s:vim_ver  " specify macro extension by vim version number
let s:text = '.mvt' " template extension

" template save in visual mode
function! Marvim_template_store()

    " yank the visual block into the default register
    " if previous command was not visual this is ignored
    " allowing for other forms of yanking
    " silent execute 'normal! `<v`>y<CR>'  

    let l:listtmp = split(@@,'\n') " get default yank buffer
    let l:template_name = input('Enter Template Name : ') 
    call writefile(l:listtmp, s:macro_home.l:template_name.s:text)
    "let l:text = getreg(g:marvim_register)
    "call setreg(g:marvim_register, 'a'.l:text)

endfunction

" hotkey mapping dynamic input function for Marvim_file_save
function! Marvim_macro_store()

    let l:macro_name = input('Enter Macro Name : ') 
    call Marvim_file_save(l:macro_name)
    " clear the command line
    echo '' 

endfunction

" The macro save function
function! Marvim_file_save(macro_name)

    "let l:listtmp = [@c] " get the macro from register c
    let l:listtmp = [getreg(g:marvim_register)]
    call writefile(l:listtmp, s:macro_home.a:macro_name.s:ext, 'b')

endfunction

" Run the macro file
" @param macro_file - full path to the macro file
function! Marvim_file_run(macro_file)

    " find if it is a template or a macro
    let l:t = split(a:macro_file, '\.')
    let s:macro_type = l:t[-1] " get the extension

    if s:macro_type == s:text[1:]  " 'mvt' read template 

        silent execute 'read '.a:macro_file
        "echo 'Read Template '.a:macro_file

    else  " a vim macro
        " execute 'so! '.s:macro_home.a:macro_name.s:ext
        
        " read the macro file into the register and run it
        let l:macro_content = readfile(a:macro_file,'b')
        call setreg(g:marvim_register,l:macro_content[0]) 
        silent execute 'normal @'.g:marvim_register
        "echo 'Ran Macro '.a:macro_file

    endif

endfunction

" Macro find
function! Marvim_search()

   let l:search_string = input('Macro Search : ')

   "let l:search_list = glob(s:macro_home.'**'.l:search_string.'**') 
   let l:search_list = glob(s:macro_home.'**') 

   " split globbed files into a list
   "let l:macro_list = split(l:search_list, '\n')  
   let l:asearch_list = split(l:search_list, '\n')  
   let l:macro_list = filter(l:asearch_list, 'v:val =~ "'.l:search_string.'" && v:val =~ "mv"')

   " filter each item in the list
   let l:item_count = 0
   for l:item in l:macro_list

        let l:item_count = l:item_count + 1

        " get the filename
        let l:dir_split = split (l:item, s:path_seperator) 
        let l:filename = l:dir_split[-1]

        " remove trailing extension
        let l:name_split = split (l:filename, '\.') " TODO: can break on multiple .

        " display each option in a list with the type of macro
        echo l:item_count.'. '.l:name_split[0].' ('.l:name_split[-1].')' 

   endfor 

   if l:item_count == 0

       echo "No Matches Found"

   elseif l:item_count == 1 " if exact match is found execute it

       call Marvim_file_run(l:macro_list[0])
       "echo "Exact Match Found and Run" 

   else " otherwise list possibilities and let user choose

       let l:item_count = input('Select Macro to Run? (Default none) :')

       if l:item_count != '' 
           call Marvim_file_run(l:macro_list[l:item_count - 1])
       endif
   endif

endfunction
