define program
  [repeat something]
end define

define something
  [number] | '#
end define

function main
  replace [program]
    P [program]
  by
    P [apply_filtering]
end function

rule apply_filtering
  replace $ [something]
    X [something]
  construct X_v [stringlit]
    _ [__POI_get__something X]
  construct __VOID__ [any]
    % void
  where
    __VOID__ [equal X_v "2"] [equal X_v "5"]
  by
    '#
end rule

function equal A [stringlit] B [stringlit]
  match [any]
    _ [any]
  where
    A [= B]
end function

function __POI_get__something X [something]
  replace [stringlit]
    _ [stringlit]
  deconstruct X
    V [number]
  construct __VALUE__ [stringlit]
    _ [quote V]
  by
    __VALUE__
end function
