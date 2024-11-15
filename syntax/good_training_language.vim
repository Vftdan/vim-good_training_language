" Vim syntax file
scriptencoding utf-8

if !exists('main_syntax')
  if version < 600
    syntax clear
  elseif exists('b:current_syntax')
    finish
  endif
  let main_syntax = 'good_training_language'
endif

if version < 508
  command! -nargs=+ GoodTrainingLanguageHiLink highlight link <args>
else
  command! -nargs=+ GoodTrainingLanguageHiLink highlight default link <args>
endif

function! s:hi_link_first(matchers, highlighters)
  let l:rhs = ''
  for l:hi in a:highlighters
    if hlexists(l:hi)
      let l:rhs = l:hi
    elseif hlexists('Nvim' . l:hi)
      let l:rhs = 'Nvim' . l:hi
    else
      continue
    endif
    break
  endfor
  if l:rhs == ''
    return
  end
  let l:cmd = 'highlight default link '
  if version < 508
    let l:cmd = 'highlight link '
  endif
  for l:lhs in a:matchers
    exe l:cmd . l:lhs . ' ' . l:rhs
  endfor
endfunction

" Keywords:
syn keyword goodtraininglanguageFunctionKeyword про nextgroup=goodtraininglanguageFuncSig
syn keyword goodtraininglanguageLoopKeyword для пока
syn keyword goodtraininglanguageConditionKeyword если иначе
syn keyword goodtraininglanguageSwitchKeyword вилка
syn keyword goodtraininglanguageCaseKeyword когда
syn keyword goodtraininglanguageDefaultKeyword любое
syn keyword goodtraininglanguageBlockKeyword то
syn region goodtraininglanguageBlock matchgroup=goodtraininglanguageBlockKeyword start=/\v<нч>/ end=/\v<кц>/ transparent
syn keyword goodtraininglanguageDeclarationKeyword пер конст nextgroup=goodtraininglanguageTypedVar
syn keyword goodtraininglanguageReturnKeyword вернуть
syn keyword goodtraininglanguageBoolopKeyword и или либо не
syn keyword goodtraininglanguageCastKeyword как nextgroup=@goodtraininglanguageType
syn keyword goodtraininglanguageImportKeyword вкл библ
syn keyword goodtraininglanguageExternKeyword внешняя
syn keyword goodtraininglanguageNewtypeKeyword структ
syn keyword goodtraininglanguageBoollitKeyword истина ложь
syn keyword goodtraininglanguageBitshiftKeyword лбс пбс
syn keyword goodtraininglanguageArithmeticKeyword ост
syn match goodtraininglanguageBuiltinFunction /\v<(печать|ввод|срез|сисвызов|размер|адрес)>(\s*\()@=/

" Strings:
syn region goodtraininglanguageDquoteString matchgroup=goodtraininglanguageQuote start='"' end='"' contains=@goodtraininglanguageStringContent
syn region goodtraininglanguageAngquoteString matchgroup=goodtraininglanguageQuote start='«' end='»' contains=@goodtraininglanguageStringContent
syn cluster goodtraininglanguageStringContent contains=@goodtraininglanguageStringEscape,goodtraininglanguageBalancedAngquotes
syn region goodtraininglanguageBalancedAngquotes matchgroup=goodtraininglanguageString start='«' end='»' transparent contained contains=@goodtraininglanguageStringContent
syn cluster goodtraininglanguageStringEscape contains=goodtraininglanguageStringNonprintEscape,goodtraininglanguageStringSpecialEscape,goodtraininglanguageStringInvalidEscape
syn match goodtraininglanguageStringInvalidEscape /\v\\/ contained
syn match goodtraininglanguageStringNonprintEscape /\v\\[нт]/ contained contains=goodtraininglanguageStringEscapeBackslash
syn match goodtraininglanguageStringSpecialEscape /\v\\["«»\\]/ contained contains=goodtraininglanguageStringEscapeBackslash
" Distinguish escaping and escaped backslashes
syn match goodtraininglanguageStringEscapeBackslash '\\' contained nextgroup=goodtraininglanguageStringEscapeBackslashAfter
syn match goodtraininglanguageStringEscapeBackslashAfter /\v./ contained transparent contains=NONE

" Numbers:
syn match goodtraininglanguageInteger /\v<[0-9]+(цел|нат8?)?/
syn match goodtraininglanguageFloat /\v<[0-9]+\.([0-9]+|\ze[^.]|$)/
syn match goodtraininglanguageHexInt /\v<16\%[0-9АБЦДЕФабцдеф]+(цел|нат8?)?/

" Variables & types:
syn match goodtraininglanguageTypedVar /\v\s*<.{-}>\s*\:\s*<.{-}>/ contained transparent contains=goodtraininglanguageColonType
syn region goodtraininglanguageColonType contained matchgroup=goodtraininglanguageColon start=/\v\s*\:/ end=/\v[^[:space:]:]@<=/ transparent contains=@goodtraininglanguageType
syn region goodtraininglanguageFuncSig contained matchgroup=goodtraininglanguageFuncNameParens start=/\v\s*<\S{-}>\s*\(/ end='\V)' transparent contains=goodtraininglanguageTypedVar,goodtraininglanguageComma nextgroup=goodtraininglanguageColonType
syn cluster goodtraininglanguageType contains=goodtraininglanguagePrimitiveType,goodtraininglanguageGenericType
syn match goodtraininglanguagePrimitiveType /\v\s*<[^[:punct:][:space:]]{-}>/ contained contains=goodtraininglanguageBuiltinType
syn region goodtraininglanguageGenericType start=/\v\s*<[^[:punct:][:space:]]{-}>\s*\(/ end='\V)' contained contains=@goodtraininglanguageType
syn keyword goodtraininglanguageBuiltinType цел нат нат8 вещ строка лог массив срез contained

" Operators:
syn match goodtraininglanguageArithmeticOp /\v[+-/*]/
syn match goodtraininglanguageBoolOp /\v\!/
syn region goodtraininglanguageNestingParenthesisBody matchgroup=goodtraininglanguageNestingParenthesis start='(' end=')' transparent
syn region goodtraininglanguageCallingParenthesisBody matchgroup=goodtraininglanguageCallingParenthesis start=/\v%(%([^[:punct:][:space:]]|\))\s*)@<=\(/ end=')' transparent
syn match goodtraininglanguageFieldOp '\V.'
syn match goodtraininglanguageRangeOp '\V..'
syn match goodtraininglanguageComma '\V,'
syn match goodtraininglanguageSemicolon '\V;'
syn match goodtraininglanguageAssignment '\V:='
syn match goodtraininglanguageComparisonOp /\v[+-]\?\=?|\!?\=/

" Comments:
syn keyword goodtraininglanguageTodo TODO FIXME СДЕЛАТЬ contained
syn region goodtraininglanguageBlockComment start="\V/*" end="\V*/" contains=goodtraininglanguageTodo
syn region goodtraininglanguageLineComment start="\V//" end=/\v$/ keepend contains=goodtraininglanguageTodo

GoodTrainingLanguageHiLink goodtraininglanguageBlockComment goodtraininglanguageComment
GoodTrainingLanguageHiLink goodtraininglanguageLineComment goodtraininglanguageComment
GoodTrainingLanguageHiLink goodtraininglanguageFunctionKeyword goodtraininglanguageKeyword
GoodTrainingLanguageHiLink goodtraininglanguageLoopKeyword goodtraininglanguageRepeat
GoodTrainingLanguageHiLink goodtraininglanguageConditionKeyword goodtraininglanguageConditional
GoodTrainingLanguageHiLink goodtraininglanguageSwitchKeyword goodtraininglanguageKeyword
GoodTrainingLanguageHiLink goodtraininglanguageCaseKeyword goodtraininglanguageLabel
GoodTrainingLanguageHiLink goodtraininglanguageDefaultKeyword goodtraininglanguageLabel
GoodTrainingLanguageHiLink goodtraininglanguageBlockKeyword goodtraininglanguageKeyword
GoodTrainingLanguageHiLink goodtraininglanguageDeclarationKeyword goodtraininglanguageStorageClass
GoodTrainingLanguageHiLink goodtraininglanguageReturnKeyword goodtraininglanguageKeyword
GoodTrainingLanguageHiLink goodtraininglanguageBoolopKeyword goodtraininglanguageOperator
GoodTrainingLanguageHiLink goodtraininglanguageCastKeyword goodtraininglanguageOperator
GoodTrainingLanguageHiLink goodtraininglanguageImportKeyword goodtraininglanguageInclude
GoodTrainingLanguageHiLink goodtraininglanguageExternKeyword goodtraininglanguageKeyword
GoodTrainingLanguageHiLink goodtraininglanguageNewtypeKeyword goodtraininglanguageNewtype
GoodTrainingLanguageHiLink goodtraininglanguageBoollitKeyword goodtraininglanguageBoolean
GoodTrainingLanguageHiLink goodtraininglanguageBitshiftKeyword goodtraininglanguageOperator
GoodTrainingLanguageHiLink goodtraininglanguageArithmeticKeyword goodtraininglanguageOperator
GoodTrainingLanguageHiLink goodtraininglanguageBuiltinFunction goodtraininglanguageOperator
GoodTrainingLanguageHiLink goodtraininglanguageDquoteString goodtraininglanguageString
GoodTrainingLanguageHiLink goodtraininglanguageAngquoteString goodtraininglanguageString
GoodTrainingLanguageHiLink goodtraininglanguageStringInvalidEscape goodtraininglanguageError
GoodTrainingLanguageHiLink goodtraininglanguageStringNonprintEscape goodtraininglanguageStringEscape
GoodTrainingLanguageHiLink goodtraininglanguageStringSpecialEscape goodtraininglanguageStringEscape
" Users may want to define non-default links to reduce color changes
GoodTrainingLanguageHiLink goodtraininglanguageStringEscape Special
GoodTrainingLanguageHiLink goodtraininglanguageStringEscapeBackslash Noise
GoodTrainingLanguageHiLink goodtraininglanguageHexInt goodtraininglanguageInteger
GoodTrainingLanguageHiLink goodtraininglanguageColon Special
GoodTrainingLanguageHiLink goodtraininglanguageFuncNameParens Function
GoodTrainingLanguageHiLink goodtraininglanguagePrimitiveType goodtraininglanguageType
GoodTrainingLanguageHiLink goodtraininglanguageGenericType goodtraininglanguageType

call s:hi_link_first(['goodtraininglanguageAssignment'], ['PlainAssignment', 'Assignment', 'Operator'])
call s:hi_link_first(['goodtraininglanguageNestingParenthesis'], ['NestingParenthesis', 'Parenthesis', 'Delimiter'])
call s:hi_link_first(['goodtraininglanguageCallingParenthesis'], ['CallingParenthesis', 'Parenthesis', 'Delimiter'])
call s:hi_link_first(['goodtraininglanguageFieldOp'], ['Subscript', 'Delimiter'])
call s:hi_link_first(['goodtraininglanguageComma'], ['Comma', 'Delimiter'])
call s:hi_link_first(['goodtraininglanguageSemicolon'], ['Semicolon', 'Statement'])
GoodTrainingLanguageHiLink goodtraininglanguageComparisonOp Operator
GoodTrainingLanguageHiLink goodtraininglanguageArithmeticOp Operator
GoodTrainingLanguageHiLink goodtraininglanguageBoolOp Operator
GoodTrainingLanguageHiLink goodtraininglanguageRangeOp Repeat

GoodTrainingLanguageHiLink goodtraininglanguageTodo Todo
GoodTrainingLanguageHiLink goodtraininglanguageComment Comment
GoodTrainingLanguageHiLink goodtraininglanguageKeyword Keyword
GoodTrainingLanguageHiLink goodtraininglanguageStorageClass StorageClass
GoodTrainingLanguageHiLink goodtraininglanguageRepeat Repeat
GoodTrainingLanguageHiLink goodtraininglanguageConditional Conditional
GoodTrainingLanguageHiLink goodtraininglanguageLabel Label
GoodTrainingLanguageHiLink goodtraininglanguageOperator Operator
GoodTrainingLanguageHiLink goodtraininglanguageNewtype Structure
GoodTrainingLanguageHiLink goodtraininglanguageBoolean Boolean
GoodTrainingLanguageHiLink goodtraininglanguageInclude Include
GoodTrainingLanguageHiLink goodtraininglanguageString String
GoodTrainingLanguageHiLink goodtraininglanguageInteger Number
GoodTrainingLanguageHiLink goodtraininglanguageFloat Float
GoodTrainingLanguageHiLink goodtraininglanguageQuote Quote
GoodTrainingLanguageHiLink goodtraininglanguageError Error
GoodTrainingLanguageHiLink goodtraininglanguageType Type
call s:hi_link_first(['goodtraininglanguageBuiltinType'], ['BuiltinType', 'Type'])

delfunction s:hi_link_first
delcommand GoodTrainingLanguageHiLink

let b:current_syntax = 'good_training_language'
if main_syntax ==# 'good_training_language'
  unlet main_syntax
endif

" vim: ts=2 sw=0 et
