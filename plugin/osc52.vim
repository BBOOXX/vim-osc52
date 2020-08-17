" vim: ts=2 sts=2 sw=2
if exists("g:loaded_YankTextToClipboardByOsc52")
  finish
endif
let g:loaded_YankTextToClipboardByOsc52 = 1

function! s:SendViaOSC52(text)
  let encodedText=substitute(a:text, '\', '\\', 'g')
  if has('macunix')
    let encodedText=system('base64 | tr -d \\n', encodedText)
  elseif has('unix')
    let encodedText=system('base64 --wrap=0 | tr -d \\n', encodedText)
  endif
  " tmux requires unrecognized OSC sequences to be wrapped with <DCS>tmux;<sequence><ST>,
  " and for all ESCs in <sequence> to be replaced with ESC ESC.
  " It only accepts ESC backslash for ST.
  let OSC = $TMUX != "" ? '\ePtmux;\e\e]' : '\e]'
  let ST = $TMUX != "" ? '\a\e\\' : '\a'
  " OSC Ps => 52 Manipulate Selection Data
  " see: https://is.gd/nJzw3j
  let executeCmd=OSC.'52;c;'.encodedText.ST
  call system('echo -en "'.executeCmd.'" > /dev/tty')
  "redraw!
endfunction

if v:version<800
  nnoremap <silent>yy yy:<C-u>call <SID>SendViaOSC52(getreg('"'))<CR>
  vnoremap <silent>y y:<C-u>call <SID>SendViaOSC52(getreg('"'))<CR>
elseif exists('##TextYankPost') == 1
  augroup osc52
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | silent! call <SID>SendViaOSC52(join(v:event.regcontents,"\n")) endif
  augroup END
endif
