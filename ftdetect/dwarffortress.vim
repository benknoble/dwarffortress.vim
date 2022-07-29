" The raw file format is fairly awful, but it does have a prescribed header we
" can check for.

autocmd BufNewFile,BufRead *.txt
      \  if g:dwarffortress_always
      \|   set filetype=dwarffortress
      \| elseif g:dwarffortress_guess
      \|   call s:DwarfFortressDetect()
      \| endif

const s:types = #{
      \ init: '%(sound|windowedx|vsync)',
      \ d_init: 'autobackup',
      \ world_gen: 'world_gen',
      \ colors: 'black_r',
      \ announcements: 'reached_peak',
      \ interface: 'bind',
      \ }

function s:token_pattern(pat) abort
  return printf('\v\c\[\s*%s\s*[\]:]', a:pat)
endfunction

function s:DwarfFortressDetect() abort
    " raw.txt contents:
    " raw
    " This is a raw file.
    " [OBJECT:SOMETHING]
    " ...
    "
    const contents = getline(1, min([line('$'), 20]))
    const stem = expand('<afile>:t:r')

    if getline(1) =~? '\V'.stem && match(contents, s:token_pattern('object')) >= 0
      set filetype=dwarffortress
      return
    endif

    for [type, pattern] in items(s:types)
      if stem ==? type && match(contents, s:token_pattern(pattern)) >= 0
        set filetype=dwarffortress
        return
      endif
    endfor
endfunction
