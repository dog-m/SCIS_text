define program
  [statement]
end define

define statement
      [number_or_id]
  |   [block]
end define

define block
  [NL] '( [NL] [IN] [repeat statement] [EX] [NL] ') [NL]
end define

define number_or_id
      [number]
  |   '#
end define

function main
  export LEVEL [number] % базовый уровень (первый встреченный)
    '1

  replace [program]
    P [program]
  by
    P [apply_filtering]
end function

%(

### полагаясь на порядок обхода:
1. вход: голова и хвост последовательности
2. если УРОВЕНЬ = 1 и голова = 2, то вернуть
    Х + хвост
2. выделить голову хвоста
3. если голова хвоста - скобочки, то
4. увеличить УРОВЕНЬ
5. иначе, если голова хвоста - пустота, то
6. уменьшить УРОВЕНЬ

)%

rule apply_filtering
  replace $ [repeat statement]
    __ITEM__  [statement] __REST__ [repeat statement]

  construct __HEAD__ [repeat statement]
    __REST__ [head 1]

  import LEVEL [number]
  construct CURRENT_LVL [number]
    LEVEL

  % сначала обновляем уровень
  where
    __HEAD__ [dec_LEVEL] [inc_LEVEL] [TRUE]

  % а уже потом проверяем (порядок важен!)
  where
    CURRENT_LVL [= 1]
  
  construct __NEW_ARRAY__ [repeat statement]
    __ITEM__
  
  by
    __NEW_ARRAY__ [process_statement]
    [. __REST__]
end rule


function process_statement
  replace [repeat statement] % на входе всегда один элемент + пустота
    __NODE__ [number]
  where
    __NODE__ [= 2]
  by
    '#
end function


function TRUE
  match [any] _ [any]
end function


function inc_LEVEL
  match [repeat statement]
    _ [block] _ [repeat statement]
  import
    LEVEL [number]
  export LEVEL
    LEVEL [+ 1]       [message "+1"]
end function


function dec_LEVEL
  match [repeat statement]
    _ [empty]
  import LEVEL [number]
  export LEVEL
    LEVEL [- 1]       [message "-1"]
end function
