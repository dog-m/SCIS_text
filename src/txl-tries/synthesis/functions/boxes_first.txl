define program
    [sequence]
end define

define sequence
    [repeat box]
end define

define box
    [item] |
    [red] | [green] | [blue] % if_statement, for_statement ...
end define

define item
    '# | [number] | [id]
end define

define red
    [NL] '[ [NL] [IN] [sequence] [EX] [NL] '] [NL]
end define

define green
    [NL] '( [NL] [IN] [sequence] [EX] [NL] ') [NL]
end define

define blue
    [NL] '< [NL] [IN] [sequence] [EX] [NL] '> [NL]
end define

% ----------------------

function main
  replace [program]
    P [program]
  by
    P [process_only_first_box]
end function

% ----------------------

function process_only_first_box
  replace * [repeat box]
    __RED_BOX__ [red] __TAIL__ [repeat box]

  where
    __RED_BOX__ [do_nothing]    % проверки/фильтрация по критериям/шаблону

  construct __SINGLE_BOX_ARRAY__ [repeat box]
    __RED_BOX__
    % +empty

  construct __PROCESSED__ [repeat box]
    __SINGLE_BOX_ARRAY__ [process_box]

  by
    __PROCESSED__ [. __TAIL__]
end function

function do_nothing
  match [any] _ [any]
end function

% ----------------------

function process_box
  replace [repeat box] % на входе всегда один элемент + пустота, чтобы можно было заменить его на последовательность
    __ORIGIN__ [box]
  by
    '#
    '[ BEFORE first ']
    __ORIGIN__
    '[ AFTER first ']
    '#
end function
