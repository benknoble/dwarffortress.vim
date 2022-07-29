if exists("b:current_syntax")
  finish
endif

" header should match filename
" don't bother to cope with name changes
syntax match dfHeaderError contained '\v%^.*$'
execute 'syntax match dfHeader contained ''\V\%^'.expand('%:t:r').'\$'''

" the whole file is a "comment" that contains other things
" note that this starts at the beginning and ends of lines, but does NOT have
" keepend, so contents can be longer than a single line
" this keeps the hilighting from breaking when earlier parts of the file are
" ignored
syntax region dfDefaultComment start='\v^' end='\v$' contains=dfHeaderError,dfHeader,dfObjectToken,dfObjectDefToken,dfTokenGeneric

" all tokens match this
syntax match dfTokenGeneric contained '\v\[[^\[\]]*\]' contains=@dfTokenSeps,dfTokenFront,dfNumber,dfChar,dfEnum,dfKwarg

syntax match dfTokenStart '\v\[' contained
syntax match dfTokenEnd '\v\]' contained
syntax match dfTokenSep '\v:' contained
syntax cluster dfTokenSeps contains=dfTokenStart,dfTokenEnd,dfTokenSep

" defines dfEnum, which is all special NAMES built-in to the game
" that don't start tokens (e.g. ALL)
" you have to compile this by hand, sorry
syntax include syntax/dwarffortressenum.vim

" generic token handling
" first element of token
syntax match dfTokenFront contained '\v\[[^\[\]:]*' contains=dfTokenName,@dfTokenSeps
" defines dfTokenName, which holds the [FIRST_WORD: of all tokens
" to update with new raws:
"   $ cd df_linux # or equivalent
"   $ grep -P '(?<=\[)[^\]\[\:]+' data/init/*.txt raw/graphics/*.txt raw/objects/*.txt -oh \
"       | sort | uniq | gsed ':a;N;$!ba;s/\n/ /g' | gfold -s | gsed 's/CONTAINS//g' \
"       | gsed 's/^/syntax keyword dfTokenName contained /' \
"       > /path/to/dwarffortress.vim/syntax/dwarffortresstokens.vim
"
" (where gsed and gfold are the gnu versions of sed and fold)
syntax include syntax/dwarffortresstokens.vim

syntax match dfNumber '\v[0-9]+%( |:|\])@=' contained
syntax match dfChar  +\v'.'+ contained

" names often used as keyword-arguments [...:BY_CATEGORY:BEES] or whatever
syntax keyword dfKwarg contained BY_CATEGORY BY_TYPE BY_TOKEN SEV PROB BP

" pull the object header from the current file
let s:object_type_regex = '\v\[\s*OBJECT\s*:\s*\zs\i+\ze\s*\]'
let [s:lnum, s:col] = searchpos(s:object_type_regex, 'n')

if s:lnum
  " we have a match!
  let s:object_type = matchstr(getline(s:lnum), s:object_type_regex)

  " higher priority than a generic token (since we're lower in this file)
  syntax match dfObjectToken contained '\v\[\s*OBJECT\s*:\s*\i+\s*\]' contains=@dfTokenSeps,dfObjectType

  execute 'syntax match dfObjectDefToken contained ''\v\[\s*'.s:object_type.'\s*:\s*\i+\s*\]'' contains=@dfTokenSeps,dfObjectType'

  if s:object_type ==? 'ITEM'
    syntax keyword dfObjectType ITEM ITEM_AMMO ITEM_ARMOR ITEM_FOOD ITEM_GLOVES
    syntax keyword dfObjectType ITEM_HELM ITEM_INSTRUMENT ITEM_PANTS ITEM_SHIELD
    syntax keyword dfObjectType ITEM_SHOES ITEM_SIEGEAMMO ITEM_TOOL ITEM_TOY ITEM_TRAPCOMP
    syntax keyword dfObjectType ITEM_WEAPON
  else
    execute 'syntax keyword dfObjectType '.toupper(s:object_type)
  endif
endif

highlight link dfDefaultComment Comment

highlight link dfHeader Underlined
highlight link dfHeaderError Error

highlight link dfObjectToken Special
highlight link dfObjectType Structure
highlight link dfObjectDefToken Identifier

highlight link dfTokenStart NONE
highlight link dfTokenEnd   NONE
highlight link dfTokenSep   Delimiter

highlight link dfKwarg Statement

" unrecognized tokens are errors
highlight link dfTokenFront Error
highlight link dfTokenName Statement

highlight link dfTokenGeneric NONE

highlight link dfEnum Constant

highlight link dfNumber Number
highlight link dfChar Character

let b:current_syntax = "dwarffortress"
