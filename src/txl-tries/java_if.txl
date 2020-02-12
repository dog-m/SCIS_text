include "java.grm"

function main
  replace [program]
    Program [program]

  where
    Program [checkClassNameAndThenMethodName]

  by 
    Program
      [addImports]
      [addLoggingFields]
      [addLoggingInitialization]
      [instrumentClassDeclarationWhereClassNameEqMain]
      [simplify]

end function



function checkClassNameAndThenMethodName
  match * [class_declaration]
    ClassHeader [class_header] ClassBody [class_body]

  deconstruct [class_header] ClassHeader
    _1 [repeat modifier] 'class ClassName [class_name] _3 [opt extends_clause] _4 [opt implements_clause]

  export ClassName

  construct ClassName_str [stringlit]
    _ [quote ClassName]

  where
    ClassName_str [= "Main"]

  where
    ClassBody [checkMethodName]

end function



function checkMethodName
  match * [method_declaration]
    _1 [repeat modifier] _2 [opt generic_parameter] _3 [type_specifier] MethodName [method_name] '( _4 [list formal_parameter] ') _5 [repeat dimension] _7 [opt throws]
    _8 [method_body]

  export MethodName

  construct MethodName_str [stringlit]
    _ [quote MethodName]

  where
    MethodName_str [= "main"]

end function




function addImports
  replace * [repeat import_declaration]
    Imports [repeat import_declaration]

  construct Additions [repeat import_declaration]
    'import java.util.List;
    'import java.util.HashSet;

  by
    Imports
      [addToImportsIfNotExists each Additions]

end function



function addToImportsIfNotExists Addition [import_declaration]
  replace [repeat import_declaration]
    Imports [repeat import_declaration]

  deconstruct not * [import_declaration] Imports
    Addition

  by
    Imports [^ Addition]

end function



rule addLoggingInitialization
  replace $ [method_declaration]
    Modifiers [repeat modifier] OptGeneric [opt generic_parameter] Type [type_specifier] MethodName [method_name] '( Parameters [list formal_parameter] ') Dimensions [repeat dimension] OptTrows [opt throws]
    Block [block]
    % важно!!! (block вместо method_body)

  construct MethodName_str [stringlit]
      _ [quote MethodName]

  where
      MethodName_str [= "main"]

  by
    Modifiers OptGeneric Type MethodName '( Parameters ') Dimensions OptTrows
    '{
      instrumentationHandler.setLevel(Level.ALL);
      instrumentationLogger.addHandler(instrumentationHandler);
      instrumentationLogger.setLevel(Level.ALL);

      Block
    '}

end rule




rule addLoggingFields
  replace $ [class_or_interface_body]
    '{
       RepDeclarations [repeat class_body_declaration]
    '} OptComa [opt ';]

  construct NewFields [repeat class_body_declaration]
    private static final Logger instrumentationLogger = Logger.getLogger(Main.class.getSimpleName());
    private static final Handler instrumentationHandler = newConsoleHandler();

  by
    '{
       NewFields [. RepDeclarations]
    '} OptComa

end rule



rule instrumentClassDeclarationWhereClassNameEqMain
  replace $ [class_declaration]
    ClassHeader [class_header] ClassBody [class_body]

  deconstruct [class_header] ClassHeader
    Modifiers [repeat modifier] 'class ClassName [class_name] OptExtendsClause [opt extends_clause] OptImplementsClause [opt implements_clause]

  construct ClassName_str [stringlit]
    _ [quote ClassName]

  where
    ClassName_str [= "Main"]

  export ClassName

  by
    ClassHeader ClassBody
      [instrumentMethodDeclarationWhereMethodNameEqMain]

end rule



rule instrumentMethodDeclarationWhereMethodNameEqMain
  replace $ [method_declaration]
    Modifiers [repeat modifier] OptGeneric [opt generic_parameter] Type [type_specifier] MethodName [method_name] '( Parameters [list formal_parameter] ') Dimensions [repeat dimension] OptTrows [opt throws]
    Body [method_body]

  construct MethodName_str [stringlit]
    _ [quote MethodName]

  where
    MethodName_str [= "main"]

  export MethodName   % передача данных о функции через глобальное окружение (тип указывать не обязательно)

  by
    Modifiers OptGeneric Type MethodName '( Parameters ') Dimensions OptTrows
    Body [instrumentIfStatement]

end rule



function instrumentIfStatement
  replace * [statement]
    IfStatement [if_statement]      % работает исходя из того, что block среди statement

  construct LOCATION [stringlit]
    _ [+ "Entering to"]

  construct IfStatement_type [id]
    _ [typeof IfStatement]

  construct ITEM [stringlit]
    _ [quote IfStatement_type]    % или просто "if_statement"

  import ClassName [class_name]   % а тут тип указывать нужно
  construct CLASS [stringlit]
    _ [quote ClassName] [+ ".java"]

  import MethodName [method_name]   % а тут тип указывать нужно
  construct METHOD [stringlit]
    _ [quote MethodName]

  construct Message_str [stringlit]
    _ [+ LOCATION] [+ " "] [+ ITEM] [+ " block in "] [+ CLASS] [+ " class, in "] [+ METHOD] [+ " method"]

  by
    '{
      instrumentationLogger.log'(Level.FINE, Message_str');

      IfStatement
    '}
end function



rule simplify
  replace [block]
    '{'{ Statements [repeat declaration_or_statement] '}'}

  by
    '{ Statements '}

end rule

