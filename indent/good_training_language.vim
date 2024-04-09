" Vim indent file
scriptencoding utf-8

" Only load this indent file when no other was loaded.
if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal indentexpr=indent#good_training_language#get_indent(v:lnum)
setlocal indentkeys+=0=кц
setlocal autoindent
" 'indentkeys' doesn't seem to handle unicode properly
inoreabbr <buffer> кц кц<C-F>
inoremap <buffer> <expr> <CR> getline('.') =~ '\v^\s*кц>$' ? '<c-o>==<c-o>o' : '<cr>'

let s:LOOKUP_DELTA = {
      \ 'нч': 1,
      \ '(': 1,
      \ '«': 1,
      \ 'кц': -1,
      \ ')': -1,
      \ '»': -1,
      \ }
let s:LOOKUP_EXPECT_CLOSE = {
      \ '«': '»',
      \ }

function! s:tokenize_line(s)
  let l:token_ptn = '[«»()]|<нч>|<кц>|<то>|<про>|<если>|<пока>|<для>|\;|\/\/'
  let l:split_ptn = '\v%(' . l:token_ptn . ')@=|%(' . l:token_ptn . ')@<=|\/\*.{-}%(\*\/|$)|"%([^"\\]|\\.)*'
  return split(a:s, l:split_ptn)
endfunction

function! s:get_delta(line, zero_delta_to)
  if a:line =~ '\v^\s*\/\/'
    " Do not change indentation after comment lines
    return [0, 0]
  endif
  let l:tokens = s:tokenize_line(a:line)
  let l:delta = 0
  let l:zero_delta_to = a:zero_delta_to
  let l:in_block_prefix = v:false
  if match(a:line, '\v^\s*(кц>|\))') >= 0
    " Line-initial closing token should be handled on the previous line
    " (Should we add an option to use Ratliff style?)
    let l:delta += 1
  endif
  let l:expect_close = ''
  let l:inline_thens = []
  for l:tok in l:tokens
    " FIXME escaped characters in angular quotes
    if len(l:expect_close)
      if l:tok == l:expect_close
        let l:expect_close_nesting -= 1
        if l:expect_close_nesting < 1
          let l:expect_close = ''
          let l:delta = l:delta + get(s:LOOKUP_DELTA, l:tok, 0)
        endif
      elseif get(s:LOOKUP_EXPECT_CLOSE, l:tok, '') == l:expect_close
        " Nested angular quote
        let l:expect_close_nesting += 1
      endif
      continue
    endif
    let l:delta = l:delta + get(s:LOOKUP_DELTA, l:tok, 0)
    let l:expect_close = get(s:LOOKUP_EXPECT_CLOSE, l:tok, '')
    let l:expect_close_nesting = 0
    if !l:in_block_prefix && get(s:LOOKUP_DELTA, l:tok, 0) < 0 && l:delta < 1
      let l:delta += l:zero_delta_to
      let l:zero_delta_to = 0
    endif
    if l:tok =~ '\v<про>|<если>|<пока>|<для>'
      let l:in_block_prefix = v:true
    elseif l:tok =~ '\v<то>|<нч>|\;'
      let l:in_block_prefix = v:false
    end
    if l:tok == '//'
      break
    elseif l:tok == 'то'
      call add(l:inline_thens, l:delta)
      let l:delta += 1
    elseif len(l:inline_thens)
      if l:tok == ';' || l:tok == 'кц'
        while len(l:inline_thens) && l:inline_thens[-1] >= l:delta - 1 - get(s:LOOKUP_DELTA, l:tok, 0)
          let l:delta = min([l:delta, l:inline_thens[-1] + get(s:LOOKUP_DELTA, l:tok, 0)])
          call remove(l:inline_thens, -1)
        endwhile
      endif
    endif
  endfor
  " if l:in_block_prefix
  "   " Would need adjusting l:pprevline handling logic
  "   " echom 'Resetting l:zero_delta_to in line: ' . a:line
  "   let l:zero_delta_to = 0
  " end
  return [l:delta, l:zero_delta_to]
endfunction

function! s:get_matching_opening(lnum, col)
  let l:view = winsaveview()
  try
    call cursor(a:lnum, a:col)
    " TODO better detection of comments and strings
    return searchpairpos('\<нч\>\|(', '', '\<кц\>\|)', 'bn', 'getline(".")[:col(".")] =~ ' . "'" . '\v\/\/|^.*%(\*\/)?%([^"«/]|\/\*@!|"%([^"\\]|\\.)*"|«%([^\\«»]|\\.|«[^»]*»)*»)%("%([^"\\]|\\.)*|«%([^\\«»]|\\.|«[^»]*»)*|\/\*%([^*]|\*\/@!)*)$' . "'")
  finally
    call winrestview(l:view)
  endtry
endfunction

function! indent#good_training_language#get_indent(lnum)
  let l:curline = getline(a:lnum)
  " TODO: if match(l:curline, '\v^\s*иначе>') >= 0
  "       It should look for the closest 'если' above
  "       that is on the current nesting level
  if match(l:curline, '\v^\s*(кц>|\))') >= 0
    " Dedicated strategy:
    " Take the indentation level of the line of the mathcing 'нч'/'('
    " and calculate the nesting change til that opening token
    let l:matching = s:get_matching_opening(a:lnum, match(l:curline, '\v<кц>') + 1)
    if l:matching[0] < 1
      return 0
    endif
    let l:lvl = indent(l:matching[0])
    " Excluding the matching 'нч'
    let l:mline = substitute(getline(l:matching[0]), '\v%>' . (l:matching[1] - 1) . 'c.*$', '', '')
    let [l:delta, l:zero_delta_to] = s:get_delta(l:mline, 0)
    if l:delta < 1
      let l:delta += l:zero_delta_to
    endif
    let l:lvl = l:lvl + shiftwidth() * l:delta
    if l:lvl < 0
      return 0
    endif
    return l:lvl
  endif

  let l:plnum = prevnonblank(a:lnum - 1)

  if l:plnum == 0
    " Start of file
    return 0
  endif

  let l:zero_delta_to = 0
  let l:lvl = indent(l:plnum)
  let l:prevline = getline(l:plnum)
  if match(l:prevline, '\v^\s*(кц>|\))%(\s*\;)?\s*$') >= 0
    " Previous line only contains a closing token,
    " so we ignore the contents of the corresponding region
    " by considering pre-previous lines before the opening token
    " and cancelling the future adjustment caused by the closing token
    " by decreasing the indentation level
    let l:matching = s:get_matching_opening(l:plnum, match(l:prevline, '\v<кц>') + 1)
    let l:lvl -= shiftwidth()
    if l:matching[0] < 1
      return l:lvl
    endif
    let l:plnum = l:matching[0]
  endif

  let l:pplnum = prevnonblank(l:plnum - 1)
  if l:pplnum > 0
    let l:pprevline = getline(l:pplnum)
  else
    let l:pprevline = ''
  endif

  while match(l:pprevline, '\v<то\s*$') >= 0
    " Each contiguous pre-previous lines that ended with a 'то' caused a
    " one-level indentation for one statement, so now we may need to
    " outdent back if we encounter statement end by seeing
    " the delta changing from a positive value to zero
    " TODO check how our code handles 'то' token in the middle of a line
    "      the relevant code operates on the l:inline_thens variable
    "      of the s:get_delta() function
    let l:zero_delta_to -= 1
    let l:pplnum = prevnonblank(l:pplnum - 1)
    if l:pplnum > 0
      let l:pprevline = getline(l:pplnum)
    else
      let l:pprevline = ''
    endif
  endwhile
  let [l:delta, l:zero_delta_to] = s:get_delta(l:prevline, l:zero_delta_to)
  if match(l:prevline, '\v^\s*(кц>|\))') >= 0
    " If the previous line started with a closing token,
    " it should have been already outdented by one level,
    " so we need to cancel that outdent,
    " but it could have followed 'то' tokens from pre-previous lines
    " that only cause outdents starting from the current line,
    " so we make this adjustment after the s:get_delta call
    let l:delta += 1
  endif
  if match(l:curline, '\v^\s*(кц>|\))') >= 0
    " UNREACHABLE: should have been handled by a dedicated strategy
    let l:delta -= 1
  end
  if l:delta < 1
    " Apply the outdents by 'то' tokens,
    " but only detect statement end after we could have cancelled the extra
    " outdent by a closing token at the beginning of the previous line
    " to properly handle end-else(if)-begin and end-else(if)-then lines,
    " because the block end is not the outer statement end in that case
    " TODO also take this fact into account in other cases
    "      this may be hard, because it often is cannot
    "      be unambiguously mapped to a syntax tree anyway;
    "      the compiler disambiguates it in a greedy fashion
    "      by doing a token lookahead, so here it is handled correctly
    let l:delta += l:zero_delta_to
  endif
  let l:lvl = l:lvl + shiftwidth() * l:delta
  if l:lvl < 0
    return 0
  endif
  return l:lvl
endfunction

" vim: ts=2 sw=0 et
