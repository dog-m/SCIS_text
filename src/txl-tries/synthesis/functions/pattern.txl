define program
  [stringlit]
end define

function main
  replace [program]
    P [stringlit]
  by
    P [check_for_pattern__123_456_789]
end function


function check_for_pattern__123_456_789
  match [stringlit]
    __TEXT__ [stringlit]
  construct S1 [stringlit]
    __TEXT__

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STARTS WITH *something*
  construct S1_LEN [number]
    _ [# S1]
  construct P1 [number]
    _ [index S1 "123"]
  where
    P1 [= 1]                         % indexing starts with one
  construct S2 [stringlit]
    S1 [: P1 S1_LEN]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HAS *something* IN THE MIDDLE
  construct S2_LEN [number]
    _ [# S2]
  construct P2 [number]
    _ [index S2 "456"]
  where
    P2 [> 0]                          % zero = not found
  construct S3 [stringlit]
    S2 [: P2 S2_LEN]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ENDS WITH *something*
  construct S3_LEN [number]
    _ [# S3]
  construct P3 [number]
    _ [index S3 "789"] [- 1] [+ 3]    % pre-evaluated search text length
  where
    P3 [= S3_LEN]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  construct _ [any]
    _ [message "~~~ MATCH ~~~"]
end function
