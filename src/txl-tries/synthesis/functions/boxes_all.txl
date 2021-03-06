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
    P [prepare_and_do_filtering]
end function

% ----------------------

function prepare_and_do_filtering
  replace * [repeat box]
    S [repeat box]
  export __SKIP__ [number] % количество коробок, которые должны быть пропущены
    0
  by
    S [process_only_first_level_boxes]
end function

%(

### полагаясь на порядок обхода:
0. изначально "число_коробок_для_пропуска" = 0

1. вход: голова (красная коробка целиком) и хвост последовательности
2. если критерий проверки не выполняется - завершить
3. если "число_коробок_для_пропуска" больше нуля,
4. то, уменьшить это число на 1 и закончить
5. иначе (0) - данная (текущая) коробка требует обработки
6. передать для обработки коробку дальше, получив взамен набор коробок (несколько или одна)
7. записать 1 (единицу) в "число_коробок_для_пропуска" (т.е. пропустить в будущем одну коробку - текущую)
8. вернуть набор коробок с хвостом последовательности

)%

rule process_only_first_level_boxes
  replace $ [repeat box]
    __RED_BOX__ [red] __TAIL__ [repeat box]

  where
    __RED_BOX__ [do_nothing]    % проверки/фильтрация по критериям/шаблону

  import __SKIP__ [number]

  construct BOXES_TO_SKIP [number]
    __SKIP__

  where
    __SKIP__ [decrement_skip] [do_nothing]

  where
    BOXES_TO_SKIP [= 0]

  construct __SINGLE_BOX_ARRAY__ [repeat box]
    __RED_BOX__
    % +empty

  construct __PROCESSED__ [repeat box]
    __SINGLE_BOX_ARRAY__ [process_box]

  export __SKIP__ % пропуск первой следующей коробки
    1

  by
    __PROCESSED__ [. __TAIL__]
end rule


function decrement_skip
  match [any] _ [any]

  import __SKIP__ [number]

  where
    __SKIP__ [> 0]

  export __SKIP__
    __SKIP__ [- 1]
end function


function do_nothing
  match [any] _ [any]
end function

% ----------------------

function process_box
  replace [repeat box] % на входе всегда один элемент + пустота, чтобы можно было заменить его на последовательность
    __ORIGIN__ [box]
  by
    '# 'BEFORE 'all    % запрещено []
    __ORIGIN__
    '# 'AFTER 'all     % запрещено []
end function
