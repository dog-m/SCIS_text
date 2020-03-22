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
  |   [id]
end define

function main
  export LEVEL [number] % ������� ������� (������ �����������)
    '1

  replace [program]
    P [program]
  by
    P [apply_filtering]
end function

%(

### ��������� �� ������� ������:
1. ����: ������ � ����� ������������������
2. ���� ������� = 1 � ������ = 2, �� �������
    � + �����
2. �������� ������ ������
3. ���� ������ ������ - ��������, ��
4. ��������� �������
5. �����, ���� ������ ������ - �������, ��
6. ��������� �������

)%

rule apply_filtering
  replace $ [repeat statement]
    __ITEM__  [statement] __REST__ [repeat statement]

  construct __HEAD__ [repeat statement]
    __REST__ [head 1]

  import LEVEL [number]
  construct CURRENT_LVL [number]
    LEVEL

  % ������� ��������� �������
  where
    __HEAD__ [dec_LEVEL] [inc_LEVEL] [TRUE]

  % � ��� ����� ��������� (������� �����!)
  where
    CURRENT_LVL [= 1]
  
  construct __NEW_ARRAY__ [repeat statement]
    __ITEM__
  
  by
    __NEW_ARRAY__ [process_statement]
    [. __REST__]
end rule


function process_statement
  replace [repeat statement] % �� ����� ������ ���� ������� + �������
    __NODE__ [number]
  where
    __NODE__ [= 2]
  by
    'X
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
