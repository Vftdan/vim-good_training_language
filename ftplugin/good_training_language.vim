scriptencoding utf-8

setlocal matchpairs=(:)
let b:match_words = '\%(\<\%(про\|если\|иначе\|для\|пока\|структ\)\>.\{-}\)\<нч\>:\<\%(вернуть\)\>:\<кц\>,«:»,/\*:\*/'
