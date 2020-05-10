define program
  [repeat number]
end define


function main
  replace [program]
    P [repeat number]
  by
    P [add_unique_items]
end function


function add_unique_items
  replace [repeat number]
    Array [repeat number]
  construct Numbers [repeat number]
    1 2 3 4 5
  by
    Array [add_unique each Numbers]
end function


function add_unique NumberToCheck [number]
  replace [repeat number]
    SomeArray [repeat number]
  deconstruct not * [number] SomeArray
    NumberToCheck
  by
    SomeArray [. NumberToCheck]
end function
