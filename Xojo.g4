grammar Xojo;

options  {
   language=Java ;
 }
// ============================================================================
// NOTES
// ============================================================================
// Structures
// ----------
//      Structure s
//         a As Integer
//      End Structure
// Note: Strings in structures can have a different syntax (name as string*10)
//
// Constants
// ---------
// Constants declared in a module vs those local to the body of a method.
// This may end up being a compile-time error instead of a syntax error.
// Constants in the body of code can have constant expressions as their value
// whereas those defined outside of local code cannot:
//  ie/   
//      module foo
//         const bar as integer = 100 // this is ok
//         const barPlus as integer = bar + 10 // NOT ok!
//        sub baz()
//            const localbar as integer = 100 // this is ok
//            const localbarPlus1 as integer = bar + 10 // this is ok !
//            const localbarPlus2 as integer = localbar + 10 // this is ok !
//         end sub
//       end module
//
// External methods
// ----------------
// These are syntactically like declares just at a module / class level
// ie/
//     Private Soft Declare Sub Untitled2 Lib "lib" ()
//
// Menu Handlers
// -------------
// Nearly identical to a normal functions / subs
// They just state which menu action it handles and they ALWAYS return a boolean
// There MAY or MAY not be an "index parameter" passed in depending on how a person sets up the menu 
//  ie/ a menu with multiple items with the same name only differing by index will have menu handlers that get passed the INDEX param
// as well the ACTION they handle IS the name of the method
//  ie/ 	
//     Function Untitled() As Boolean Handles Untitled.Action
//			Return True
//		End Function
//     Function OtherUntitled(index as integer) As Boolean Handles OtherUntitled.Action
//			Return True
//		End Function
//
// Notes & Using clauses
// ---------------------
// These ONLY have a #tag lines in Xojo files and have no "syntax" per se
// ie/ #tag Note, Name = Untitled4
//     #tag EndNote
//
//  ie/ #tag Using, Name = Untitled3
//      #tag EndUsing

// ============================================================================
// PARSER RULES
// ============================================================================
start
    : NEWLINE* globalStatements+ EOF
    ;

globalStatements
	: attributes? globalDeclarations
	| statement
	;

globalDeclarations
  :   functionDeclaration
    | subDeclaration
	| classDeclaration
	| interfaceStatement
	| moduleDeclaration
	| structureDeclaration
	| enumStatement
	| delegateDeclaration
	;
	
// ============================================================================
// STRUCTURAL BLOCK LEVEL STATEMENTS
// ============================================================================
attributes
	: ATTRIBUTES '(' attribute (',' attribute)* ')'	
	;

attribute:
		attributeName ('='(fqName | literal))?
	;

attributeName:
		IDENTIFIER
	|	STRING
	;


moduleDeclaration
    : attributes? scope? MODULE IDENTIFIER NEWLINE+  
        ( 
            classDeclaration
          | moduleDeclaration
          | interfaceStatement
          | constStatement NEWLINE+  
          | functionDeclaration
          | subDeclaration
          | propertyDeclaration 
          | delegateDeclaration
          | enumStatement
          | externalMethodDeclaration
          | structureDeclaration
          | usingStatement
        )*
      END MODULE NEWLINE+
    ;
    
classDeclaration
    : attributes? scope? CLASS IDENTIFIER NEWLINE? (INHERITS fqName)? NEWLINE? (IMPLEMENTS fqName (',' fqName)*)? NEWLINE+
        (
          menuHandlerDeclaration
        | functionDeclaration 
        | subDeclaration
        | propertyDeclaration 
        | constStatement NEWLINE+ 
        | delegateDeclaration
        | enumStatement 
        | eventDeclaration 
        | externalMethodDeclaration
        | structureDeclaration
        | usingStatement
        )*
      END CLASS NEWLINE+
    ;

enumStatement
    : scope? ENUM IDENTIFIER NEWLINE+
      enumEntry+
      END ENUM NEWLINE+
    ;

enumEntry
    : IDENTIFIER ('=' number)? NEWLINE+
    ;

externalMethodDeclaration 
    : scope? declareStatement NEWLINE+
    ;

interfaceStatement
    : scope? INTERFACE IDENTIFIER NEWLINE+
      (functionDeclaration | subDeclaration)*
      END INTERFACE NEWLINE+
    ;

menuHandlerDeclaration
     // in the case of menu handlers they ALL return BOOLEAN (not fqName) but we'd have to make types reserved and they are not
     //                              BOOLEAN        Fully qualifeid name for the menu action ?    
    : FUNCTION IDENTIFIER '(' ')' AS fqName HANDLES fqName NEWLINE+  // menu handler with no params.
      statement*
      exceptionBlock*
      END FUNCTION NEWLINE+ 
    |  FUNCTION IDENTIFIER '(' parameters ')' AS fqName HANDLES fqName NEWLINE+ // menu menu handler that _may_ have params ( menu item set )
      statement*
      exceptionBlock*
      END FUNCTION NEWLINE+ 
    ;

functionDeclaration
    : scope? (SHARED)? FUNCTION IDENTIFIER '(' ')' AS fqName NEWLINE+ 
      statement*
      exceptionBlock*
      END FUNCTION NEWLINE+ // Function with no params.
    | scope? (SHARED)? FUNCTION IDENTIFIER '(' parameters ')' AS fqName NEWLINE+
      statement*
      exceptionBlock*
      END FUNCTION NEWLINE+ // Function that _may_ have params.
    ;

subDeclaration
    : scope? (SHARED)? SUB IDENTIFIER '(' ')' NEWLINE+ 
      statement*
      exceptionBlock*
      END SUB NEWLINE+ // Sub with no params.
    | scope? (SHARED)? SUB IDENTIFIER '(' parameters ')' NEWLINE+
      statement*
      exceptionBlock*
      END SUB NEWLINE+ // Sub that _may_ have params.
    ;
  
eventDeclaration 
    : EVENT IDENTIFIER '(' parameters? ')' AS fqName NEWLINE+ #EventDefinitionFunction // Has return value
    | EVENT IDENTIFIER '(' parameters? ')' NEWLINE+ #EventDefinitionSub // No return value
    ;

delegateDeclaration
    : scope? DELEGATE FUNCTION IDENTIFIER '(' ')' AS fqName NEWLINE+ 
    | scope? DELEGATE FUNCTION IDENTIFIER '(' parameters ')' AS fqName NEWLINE+
    | scope? DELEGATE SUB IDENTIFIER '(' ')' NEWLINE+ 
    | scope? DELEGATE SUB IDENTIFIER '(' parameters ')' NEWLINE+
    ;

structureDeclaration
    : scope? STRUCTURE IDENTIFIER NEWLINE+ 
        ( structureFieldDeclaration )* 
        END STRUCTURE NEWLINE+ 
        ;

structureFieldDeclaration
    : IDENTIFIER AS ( structureString | fqName ) NEWLINE+ 
    ;

structureString 
    : IDENTIFIER STAR INTEGER
    ;

usingStatement
    : USING (GLOBAL DOT)? fqName NEWLINE+
    ;

// ============================================================================
// STATEMENTS
// ============================================================================
// Statements are "regular" statements that can occur anywhere in a program
// except for within the top level of a class, module or interface declaration.
statement
    : declaration NEWLINE+
    | addHandlerStatement NEWLINE+
    | assignmentStatement NEWLINE+
    | breakStatement NEWLINE+
    | callStatement NEWLINE+
    | callExpr NEWLINE+
    | continueStatement NEWLINE+
    | compilerDirectives NEWLINE+
    | doStatement NEWLINE+
    | exitStatement NEWLINE+
    | forEachStatement NEWLINE+
    | forNextStatement NEWLINE+    
    | gotoStatement NEWLINE+
    | ifStatement NEWLINE+
    | pragmaStatement NEWLINE+
    | raiseStatement NEWLINE+
    | raiseEventExpr NEWLINE+
    | redimStatement NEWLINE+
    | removeHandlerStatement NEWLINE+
    | returnStatement NEWLINE+
    | selectStatement NEWLINE+
    | tryCatchFinally NEWLINE+
    | usingStatement NEWLINE+
    | whileStatement NEWLINE+
    | comment NEWLINE+
    | label NEWLINE+
    ;

// ============================================================================
// SINGLE LINE STATEMENTS
// ============================================================================
// Single line statements are statements that only require one line to implement.
// They can be used in single line if statements for example.
singleLineStatement
    : callExpr
    | callStatement
    | dimStatement
    | constStatement
    | assignmentStatement
    | addHandlerStatement
    | breakStatement
    | continueStatement
    | exitStatement
    | gotoStatement
    | raiseStatement
    | raiseEventExpr
    | redimStatement
    | removeHandlerStatement
    | returnStatement
    ;

compilerDirectives
    // expr has to be a BOOLEAN expr
    : COMPILER_IF ifCondition=expr THEN? NEWLINE+ 
      statement*
      compilerElseIfClause*
      compilerElseClause?
      COMPILER_END_IF 
    ;

compilerElseIfClause
    // expr has to be a BOOLEAN expr
    : COMPILER_ELSE_IF elseIfCondition=expr THEN? NEWLINE+ 
      statement*
    ;

compilerElseClause
    : COMPILER_ELSE NEWLINE+ 
      statement*
    ;

// ----------------------
// DECLARATION STATEMENTS
// ----------------------
declaration
    : dimStatement
    | constStatement
    | declareStatement
    | propertyDeclaration
    ;

// Declare any number of variables/arrays of varying types.
dimStatement
    : (DIM | VAR) declClause ( ',' declClause)* comment? 
    ;

declClause :
	(arrayDecl | simplevarDecl ) (',' (arrayDecl | simplevarDecl))* AS newOP? fqName('(' arguments ')')? (EQUALS expr)?
	;
	
constStatement
    // Note: Xojo has two variations of this but that _may_ not be relevant 
    // since a user *cannot* declare constants outside every scope like they can in XojoScript.
    : CONST IDENTIFIER (AS fqName)? EQUALS expr
    ;

// Fails to compile if the expr is NOT a string constant.
declareStatement :
      //                                                       ALIAS                SELECTOR
	  SOFT? DECLARE FUNCTION IDENTIFIER LIB (STRING | fqName) (IDENTIFIER STRING)? (IDENTIFIER STRING)? '('  paramList  ')' AS fqName comment?
	| SOFT? DECLARE SUB      IDENTIFIER LIB (STRING | fqName) (IDENTIFIER STRING)? (IDENTIFIER STRING)? '('  paramList ')' comment?
	;

// Note for getters & setters: `Get` and `Set` are *not* reserved words so we do this in a hacky kind of way.
// Properties are basically like any other declared variable they just use PROPERTY syntax so we can 
// realize when they are computed as there is a start and an end.
// They do *not* have to have either a getter or setter (seems odd but its true).
propertyDeclaration
    : instanceComputedProperty
    | sharedComputedProperty
    | instanceProperty
    | sharedProperty
    ; 

instanceComputedProperty
    : scope? PROPERTY IDENTIFIER AS fqName NEWLINE+  
//    `Get`                                       `Get`    <<<< MUST be the identifier `Get`
      (IDENTIFIER NEWLINE+ statement* NEWLINE+ END IDENTIFIER NEWLINE+)?
//    `Set`                                       `Set`    <<<< MUST be the identifier `Set`
      (IDENTIFIER NEWLINE+ statement* NEWLINE+ END IDENTIFIER NEWLINE+)?
      END PROPERTY NEWLINE+
    ;

sharedComputedProperty
    : scope? SHARED PROPERTY IDENTIFIER AS fqName NEWLINE+  
//    `Get`                                      `Get`    <<<< MUST be the identifier `Get`
      (IDENTIFIER NEWLINE+ statement* NEWLINE+ END IDENTIFIER NEWLINE+)?
//    `Set`                                      `Set`    <<<< MUST be the IDENT `Set`
      (IDENTIFIER NEWLINE+ statement* NEWLINE+ END IDENTIFIER NEWLINE+)?
      END PROPERTY NEWLINE+
    ;

instanceProperty
    : scope? PROPERTY? IDENTIFIER AS fqName NEWLINE+ #DeclareInstanceProperty
    | scope? PROPERTY? IDENTIFIER AS fqName EQUALS expr NEWLINE+ #DeclareAndAssignInstanceProperty
    ;

sharedProperty
    : scope? SHARED PROPERTY? IDENTIFIER AS fqName NEWLINE+ #DeclareSharedProperty
    | scope? SHARED PROPERTY? IDENTIFIER AS fqName EQUALS expr NEWLINE+ #DeclareAndAssignSharedProperty
    ;

// ---------------------------
// NON-DECLARATION STATEMENTS
// ---------------------------
addHandlerStatement
    : ADD_HANDLER eventName=fqName ',' addressType=(ADDRESS_OF | WEAK_ADDRESS_OF) delegateMethod=fqName comment?
    ;

assignmentStatement
    : fqName EQUALS expr
    ;

breakStatement
    : BREAK
    ;

callStatement
    : CALL callExpr
    ;

continueStatement
    : CONTINUE comment? #Continue
    | CONTINUE FOR IDENTIFIER comment? #ContinueForWithVariable
    | CONTINUE DO comment? #ContinueDo
    | CONTINUE FOR comment? #ContinueFor
    | CONTINUE WHILE comment? #ContinueWhile
    ;

doStatement
    : DO NEWLINE+ statement* LOOP #DoUnconditional
    | (
        (DO UNTIL expr NEWLINE+ statement* LOOP)
      | (DO NEWLINE+ statement* LOOP UNTIL expr)
      | (DO UNTIL expr NEWLINE+ statement* LOOP UNTIL expr)
    ) #DoConditional
    ;

exceptionBlock
    : (CATCH|EXCEPTION) (IDENTIFIER (AS fqName)?)? NEWLINE+ 
        statement*
    ;

exitStatement
    : EXIT (SUB | FUNCTION)? comment? #ExitSubOrFunction
    | EXIT DO comment? #ExitDo
    | EXIT FOR comment? #ExitFor
    | EXIT FOR IDENTIFIER comment? #ExitForWithVariable    
    | EXIT WHILE comment? #ExitWhile
    ;

forEachStatement
    : FOR EACH IDENTIFIER (AS fqName)? IN expr NEWLINE+
      statement*
      NEXT IDENTIFIER?
    ;

forNextStatement
    : FOR counter=IDENTIFIER (AS fqName)? EQUALS forNextStartValue=expr (TO | DOWN_TO) forNextEndValue=expr (STEP expr)? NEWLINE+
       statement*
      NEXT (IDENTIFIER)?
    ;

gotoStatement
    : GOTO IDENTIFIER comment?
    ;

label
	: IDENTIFIER ':'
	;
	
ifStatement
    // expr has to be a BOOLEAN expr
    : IF ifCondition=expr THEN singleLineStatement (ELSE singleLineStatement)?
    | IF ifCondition=expr THEN NEWLINE+ statement*
      elseIfClause*
      elseClause?
      END (IF)?
    ;

elseIfClause
    : ELSE_IF elseIfCondition=expr THEN NEWLINE+ statement*
    ;

elseClause
    : ELSE NEWLINE+ statement*
    ;

newOP
    : NEW
    ;
    
pragmaStatement
    : PRAGMA fqName BOOLEAN_LITERAL  //  Background tasks etc
    | PRAGMA fqName STRING           // Warning & Error
    ;

raiseStatement
    : RAISE expr
    ;

raiseEventExpr
    : RAISE_EVENT IDENTIFIER ('(' ')')? #RaiseEventExprNoArgs
    | RAISE_EVENT IDENTIFIER '(' arguments ')' #RaiseEventExprWithArgs
    ;

redimStatement
    : REDIM IDENTIFIER '(' expr (',' expr)* ')' comment?
    ;

removeHandlerStatement
    : REMOVE_HANDLER eventName=fqName ',' addressType=(ADDRESS_OF | WEAK_ADDRESS_OF) delegateMethod=fqName comment?
    ;

returnStatement
    : RETURN value=expr? comment?
    ;

selectStatement
    : SELECT CASE selectCaseExpression=expr NEWLINE+
        caseStatement+
        caseElseStatement?
      END SELECT
    ;

caseElseStatement
    : CASE? ELSE NEWLINE+ statement*
    ;

caseStatement
    : CASE caseExpr NEWLINE+ statement* #CaseStatementSingleExpression
    | CASE caseExprList NEWLINE+ statement* #CaseStatementMultipleExpressions
    ;

caseIsExpr
    : IS unary
    | IS ('=' | '>' | '<' | '<=' | '>=' | '<>') expr
    ;

caseIsAExpr
    : ISA fqName
    ;

caseToExpr
    : expr TO expr
    ;

// The expressions valid within a case statement.
caseExpr
    : caseIsExpr 
    | caseIsAExpr
    | caseToExpr
    | expr
    ;

// A comma-separated list of expressions (valid within a case statement).
caseExprList
    : caseExpr ',' caseExpr (',' caseExpr)*
    ;

tryCatchFinally
    : tryStatement
      catchStatement+
      finallyStatement?
      END TRY   
    ;

tryStatement
    : TRY NEWLINE+ statement*
    ;

catchStatement
    : CATCH (errorParameter=IDENTIFIER (AS fqName)?)? NEWLINE+
       statement*
    ;

finallyStatement
    : FINALLY NEWLINE+ statement*
    ;

whileStatement
    : WHILE expr NEWLINE+
      statement*
      WEND
    ;

comment
    : COMMENT_APOSTROPHE
    | COMMENT_REM
    | COMMENT_SLASH
    ;

// ============================================================================
// EXPRESSIONS
// ============================================================================
expr
    : callExpr #callExpression
    | raiseEventExpr #RaiseEventExpression
    | ADDRESS_OF fqName #AddressOf
    | expr IS expr #Is
    | expr ISA fqName #IsA
    | expr CARET expr #opExponent // this should be right associative
    | unary #opUnary
    | expr STAR expr #Multiply
    | expr FORWARD_SLASH expr # DoubleDivision
    | expr BACKSLASH expr # IntegerDivision
    | expr MOD expr #Modulo
    | expr PLUS expr #Plus
    | expr MINUS expr #Subtract
    | expr (EQUALS | GREATER | LESS | GREATER_EQUAL | LESS_EQUAL | NOT_EQUAL) expr #Comparison
    | expr AND expr #BitwiseAnd
    | expr (OR | XOR) expr #BitwiseOrXor
    | expr ':' expr #PairCreation
    | primary #PrimaryExpression
    ;

// ============================================================================
// CALL EXPRESSIONS
// ============================================================================
// Xojo supports two equivalent calling conventions:
//
//   foo(t)     parenthesised — unambiguous
//   foo t      no-parens — arguments follow the name directly, no parens
//
// These are semantically identical. The no-parens form is only valid as a
// statement (i.e. the result is discarded), never as a sub-expression, because
// allowing it inside expr would make the grammar infinitely ambiguous:
//   foo bar baz   →  foo(bar(baz)) ?  or  foo(bar), baz ?
//
// To prevent this, the no-parens form uses `bareArguments` rather than
// `arguments`. `bareArguments` is a comma-separated list of `bareExpr` values,
// where `bareExpr` is like `expr` but explicitly excludes the no-parens
// `callExpr` alternative. This keeps each argument unambiguously bounded by
// the comma or end-of-line that follows it.
//
// Parenthesised calls may appear anywhere an expr is valid and use the
// unrestricted `arguments` rule, since the closing `)` provides a clear
// boundary.

callExpr
    : fqName '(' arguments? ')'            #ParenCall         // foo()  foo(a, b)
    | fqName '(' arguments? ')' '.' expr   #ParenCallChained  // foo(a).bar
    | fqName bareArguments                 #BareCall           // foo a, b  (statement position only)
    ;

// Arguments for parenthesised calls. Each argument is a full `expr`, which
// may itself contain nested callExprs of either form.
arguments
    : expr (COMMA expr)*
    ;

// Arguments for the no-parens call form. Each argument is a `bareExpr` so
// that a bare identifier following the callee is always consumed as an
// argument to this call, never as a separate statement.
bareArguments
    : bareExpr (COMMA bareExpr)*
    ;

// An expression that is safe to use as a no-parens argument: the same as
// `expr` but without the no-parens `callExpr` alternative. This means a bare
// name used as an argument is always a primary (variable/property reference),
// never silently interpreted as another no-parens call.
bareExpr
    : raiseEventExpr
    | ADDRESS_OF fqName
    | bareExpr IS bareExpr
    | bareExpr ISA fqName
    | bareExpr CARET bareExpr
    | bareUnary
    | bareExpr STAR bareExpr
    | bareExpr FORWARD_SLASH bareExpr
    | bareExpr BACKSLASH bareExpr
    | bareExpr MOD bareExpr
    | bareExpr PLUS bareExpr
    | bareExpr MINUS bareExpr
    | bareExpr (EQUALS | GREATER | LESS | GREATER_EQUAL | LESS_EQUAL | NOT_EQUAL) bareExpr
    | bareExpr AND bareExpr
    | bareExpr (OR | XOR) bareExpr
    | bareExpr ':' bareExpr
    | fqName '(' arguments? ')'            // parenthesised calls ARE allowed inside bare args
    | fqName '(' arguments? ')' '.' expr
    | primary
    ;

bareUnary
    : MINUS bareExpr
    | NOT bareExpr
    | NEW fqName ('(' arguments ')')?
    ;

unary
    : operator=MINUS expr #UnaryNegation
    | operator=NOT expr #UnaryNot
    | operator=NEW fqName ('(' arguments ')')? #UnaryNew
    ;

primary
    : groupingExpr
    | literal
    | ifExpr // Correct precedence?
    | SELF
    | SUPER
    | IDENTIFIER
    ;

groupingExpr
    : '(' expr ')'
    ;

literal
    : BOOLEAN_LITERAL
    | number
    | STRING
    | COLOR_LITERAL
    | UNICODE_LITERAL
    | NIL
    ;

ifExpr
    : IF '(' expr ',' expr ',' expr ')'
    ;

number
    : BINARY_LITERAL
    | HEX_LITERAL
    | OCTAL_LITERAL
    | INTEGER
    | DOUBLE
    ;

// ============================================================================
// HELPERS
// ============================================================================
scope
    : GLOBAL
    | PUBLIC
    | PROTECTED
    | PRIVATE
    ;

fqName // Fully Qualified name
    : IDENTIFIER (DOT IDENTIFIER)*
    | SELF (DOT IDENTIFIER)*
    | ME (DOT IDENTIFIER)*
    ;

// A parameter is the variable which is part of a function or sub's signature.
parameters
    : ASSIGNS (varParam | arrayParam) // Edge case single param using `Assigns`.
    | PARAM_ARRAY arrayParam // Edge case, single `ParamArray` param.
    | (varParamList | arrayParamList) (',' (varParamList | arrayParamList))* ((',' ASSIGNS varParam) | ASSIGNS arrayParam)? // Allow trailing `Assigns`.
    | (varParamList | arrayParamList) (',' (varParamList | arrayParamList))* (',' PARAM_ARRAY arrayParam)? // Allow trailing `ParamArray`.
    ;

refType
    : BYREF
    | BYVAL
    ;

varParam
    : (refType)? (IDENTIFIER|ME) AS fqName
    ;

varParamList
    : varParam ('=' literal | fqName)? (',' varParam ('=' literal | fqName)?)*
    ;

arrayParamList
    : arrayParam (',' arrayParam)* 
    ;

arrayParam
    :  (IDENTIFIER|ME) '(' (',')* ')' AS fqName
    ;

arrayDecl
    : simplevarDecl '(' ( MINUS? number (',' MINUS? number)* )? ')'
    ;

simplevarDecl 
	: (IDENTIFIER | ME) ;

varList
    : IDENTIFIER (',' IDENTIFIER)*
    ;

paramList
    : (IDENTIFIER AS fqName (',' IDENTIFIER AS fqName )*)?
    ;

// ==============================================================================
// LEXER RULES.
// ==============================================================================
// WHITESPACE
WHITESPACE : (' ' | '\t') -> skip;
NEWLINE : ('\r'? '\n' | '\r');

// LINE CONTINUATION
// An underscore at the end of a line (with optional trailing whitespace, and
// optionally followed by a comment) continues the logical line onto the next.
// The token is skipped entirely — the parser never sees it.
//
// Legal forms:
//   someCode _              (bare underscore, end of line)
//   someCode _ ' remark     (apostrophe comment after underscore)
//   someCode _ // remark    (double-slash comment after underscore)
//   someCode _ REM remark   (REM comment after underscore)
//
// IMPORTANT: This rule must appear before the IDENTIFIER rule in the lexer
// because '_' is also a valid identifier character. ANTLR gives priority to
// the rule defined first when both could match.
LINE_CONTINUATION
    : '_' (' ' | '\t')* (
          '\'' ~('\r' | '\n')*        // apostrophe comment
        | '//' ~('\r' | '\n')*        // double-slash comment
        | R E M ' ' ~('\r' | '\n')*  // REM comment (must have space after REM)
        )?
      ('\r'? '\n' | '\r') -> skip
    ;

// COMMENTS
COMMENT_APOSTROPHE
    : '\'' ~('\r' | '\n')* -> skip
    ;

COMMENT_REM
    : R E M ' ' ~('\r' | '\n')* -> skip
    ;

COMMENT_SLASH
    : '//' ~('\r' | '\n')* -> skip
    ;

// CASE INSENSITIVE FRAGMENTS
fragment A : ('A'|'a');
fragment B : ('B'|'b');
fragment C : ('C'|'c');
fragment D : ('D'|'d');
fragment E : ('E'|'e');
fragment F : ('F'|'f');
fragment G : ('G'|'g');
fragment H : ('H'|'h');
fragment I : ('I'|'i');
fragment J : ('J'|'j');
fragment K : ('K'|'k');
fragment L : ('L'|'l');
fragment M : ('M'|'m');
fragment N : ('N'|'n');
fragment O : ('O'|'o');
fragment P : ('P'|'p');
fragment Q : ('Q'|'q');
fragment R : ('R'|'r');
fragment S : ('S'|'s');
fragment T : ('T'|'t');
fragment U : ('U'|'u');
fragment V : ('V'|'v');
fragment W : ('W'|'w');
fragment X : ('X'|'x');
fragment Y : ('Y'|'y');
fragment Z : ('Z'|'z');

// NUMBERS
fragment DIGIT : [0-9];
fragment HEX : (DIGIT | [A-Fa-f]);

DOUBLE : DIGIT+ '.' DIGIT+ (E DIGIT+)?;
INTEGER : DIGIT+ (E DIGIT+)?;

BINARY_LITERAL : '&' B [0-1]+;
HEX_LITERAL : '&' H HEX+;
OCTAL_LITERAL : '&' O [0-7]+;

// STRINGS
fragment ESCAPED_QUOTE : '""';

STRING : '"' (~[\r\n"] | ESCAPED_QUOTE)* '"';

// OTHER LITERALS
COLOR_LITERAL: '&' C HEX+;
BOOLEAN_LITERAL : T R U E | F A L S E;
UNICODE_LITERAL : '&' U HEX+;

// COMPILER KEYWORDS
BAD: '#' B A D;
COMPILER_ELSE : '#' E L S E;
COMPILER_ELSE_IF : '#' E L S E I F;
COMPILER_END_IF : '#' E N D I F;
COMPILER_IF : '#' I F;
PRAGMA : '#' P R A G M A;
COMPILER_TAG : '#' T A G;

// KEYWORDS
ADD_HANDLER : A D D H A N D L E R;
ADDRESS_OF : A D D R E S S O F;
AGGREGATES : A G G R E G A T E S;
// ALIAS : A L I A S;
AND : A N D;
ARRAY : A R R A Y;
AS : A S;
ASSIGNS : A S S I G N S;
ASYNC : A S Y N C;
ATTRIBUTES : A T T R I B U T E S;
AWAIT : A W A I T;
BREAK : B R E A K;
BYREF : B Y R E F;
BYVAL : B Y V A L;
CALL : C A L L;
CASE : C A S E;
CATCH : C A T C H;
CLASS : C L A S S;
CONST : C O N S T;
CONTINUE : C O N T I N U E;
CTYPE : C T Y P E;
DECLARE : D E C L A R E;
DELEGATE : D E L E G A T E;
DIM : D I M;
DO : D O;
DOWN_TO : D O W N T O;
EACH : E A C H;
ELSE : E L S E;
ELSE_IF : E L S E I F;
END : E N D;
ENUM : E N U M;
EVENT : E V E N T;
EXCEPTION : E X C E P T I O N;
EXIT : E X I T;
EXTENDS : E X T E N D S;
FINALLY : F I N A L L Y;
FOR : F O R;
FUNCTION : F U N C T I O N;
GLOBAL : G L O B A L;
GOTO : G O T O;
HANDLES : H A N D L E S;
IF : I F;
IMPLEMENTS : I M P L E M E N T S;
IN : I N;
INHERITS : I N H E R I T S;
INTERFACE : I N T E R F A C E;
IS : I S;
ISA : I S A;
LIB : L I B;
LOOP: L O O P;
ME: M E;
MOD : M O D;
MODULE : M O D U L E;
NAMESPACE : N A M E S P A C E;
NEW : N E W;
NEXT : N E X T;
NIL : N I L;
NOT : N O T;
OF : O F;
OPTIONAL : O P T I O N A L;
OR : O R;
PARAM_ARRAY : P A R A M A R R A Y;
PRIVATE : P R I V A T E;
PROPERTY : P R O P E R T Y;
PROTECTED : P R O T E C T E D;
PUBLIC : P U B L I C;
RAISE : R A I S E;
RAISE_EVENT : R A I S E E V E N T;
REDIM : R E D I M;
REMOVE_HANDLER : R E M O V E H A N D L E R;
RETURN : R E T U R N;
SELECT : S E L E C T;
SELF : S E L F;
SHARED : S H A R E D;
SOFT : S O F T;
STATIC : S T A T I C;
STEP : S T E P;
STRUCTURE : S T R U C T U R E;
SUB : S U B;
SUPER : S U P E R;
THEN : T H E N;
TO : T O;
TRY : T R Y;
UNTIL : U N T I L;
USING : U S I N G;
VAR : V A R;
WEAK_ADDRESS_OF : W E A K A D D R E S S O F;
WEND : W E N D;
WHILE : W H I L E;
WITH : W I T H;
XOR : X O R;

// One we need for how strings in structures are defined.
// STRINGTYPE : S T R I N G ;

// NOT keywords but if *not* specified they get tokenised as identifiers.
// GET : G E T;
// SET : S E T;

// SYMBOLS
STAR          : '*';
FORWARD_SLASH : '/';
PLUS          : '+';
MINUS         : '-';
BACKSLASH     : '\\';
EQUALS        : '=';
NOT_EQUAL     : '<>';
GREATER       : '>';
GREATER_EQUAL : '>=';
LESS          : '<';
LESS_EQUAL    : '<=';
CARET         : '^';
COLON         : ':';
COMMA         : ',';
DOT           : '.';
LPAREN        : '(';
RPAREN        : ')';

// IDENTIFIERS
fragment
IDENTIFIER_START
    : [a-zA-Z]
    ;

// TODO: We'll want identifier characters to include pretty much any valid UTF-8 character.
// https://github.com/antlr/antlr4/blob/master/doc/unicode.md
fragment
IDENTIFIER_CHARS
    : IDENTIFIER_START
    | '_'
    | [0-9]
    | UnicodeLetter
    | UnicodeDigit
    ;

IDENTIFIER
    : IDENTIFIER_START (IDENTIFIER_CHARS)*
    ;

// From https://github.com/antlr/grammars-v4/blob/b97ad8c2147fe78677b4dac6a1da6877edf27ec5/antlr4/LexUnicode.g4
fragment UnicodeLetter 
	: [\p{Alpha}\p{General_Category=Other_Letter}\p{Alnum}\p{General_Category=Other_Letter}]
    ;

fragment UnicodeDigit // UnicodeClass_ND
	: '\u0030'..'\u0039'
	| '\u0660'..'\u0669'
	| '\u06f0'..'\u06f9'
	| '\u07c0'..'\u07c9'
	| '\u0966'..'\u096f'
	| '\u09e6'..'\u09ef'
	| '\u0a66'..'\u0a6f'
	| '\u0ae6'..'\u0aef'
	| '\u0b66'..'\u0b6f'
	| '\u0be6'..'\u0bef'
	| '\u0c66'..'\u0c6f'
	| '\u0ce6'..'\u0cef'
	| '\u0d66'..'\u0d6f'
	| '\u0de6'..'\u0def'
	| '\u0e50'..'\u0e59'
	| '\u0ed0'..'\u0ed9'
	| '\u0f20'..'\u0f29'
	| '\u1040'..'\u1049'
	| '\u1090'..'\u1099'
	| '\u17e0'..'\u17e9'
	| '\u1810'..'\u1819'
	| '\u1946'..'\u194f'
	| '\u19d0'..'\u19d9'
	| '\u1a80'..'\u1a89'
	| '\u1a90'..'\u1a99'
	| '\u1b50'..'\u1b59'
	| '\u1bb0'..'\u1bb9'
	| '\u1c40'..'\u1c49'
	| '\u1c50'..'\u1c59'
	| '\ua620'..'\ua629'
	| '\ua8d0'..'\ua8d9'
	| '\ua900'..'\ua909'
	| '\ua9d0'..'\ua9d9'
	| '\ua9f0'..'\ua9f9'
	| '\uaa50'..'\uaa59'
	| '\uabf0'..'\uabf9'
	| '\uff10'..'\uff19'
	;
