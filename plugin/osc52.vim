" vim: ts=2 sts=2 sw=2
if exists("g:loaded_YankTextToClipboardByOsc52")
  finish
endif
let g:loaded_YankTextToClipboardByOsc52 = 1

function! s:SendViaOSC52(text)
  if !has('unix')
    return
  endif
  let encodedText=system('base64', a:text)
  if v:shell_error
    return
  endif
  let encodedText=substitute(encodedText, '[\r\n]', '', 'g')
  " tmux requires unrecognized OSC sequences to be wrapped with <DCS>tmux;<sequence><ST>,
  " and for all ESCs in <sequence> to be replaced with ESC ESC.
  " It only accepts ESC backslash for ST.
  let ESC = nr2char(27)
  let BEL = nr2char(7)
  let BSLASH = nr2char(92)
  let OSC = $TMUX != "" ? ESC.'Ptmux;'.ESC.ESC.']' : ESC.']'
  let ST = $TMUX != "" ? BEL.ESC.BSLASH : BEL
  " OSC Ps => 52 Manipulate Selection Data
  " see: https://is.gd/nJzw3j
  let executeCmd=OSC.'52;c;'.encodedText.ST
  silent! call writefile([executeCmd], '/dev/tty', 'b')
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
