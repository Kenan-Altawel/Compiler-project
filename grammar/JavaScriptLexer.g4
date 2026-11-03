
lexer grammar JavaScriptLexer;

// ==========================================
// 1. Reserved Keywords
// ==========================================

BREAK       : 'break';
CASE        : 'case';
CATCH       : 'catch';
CLASS       : 'class';
CONST       : 'const';
CONTINUE    : 'continue';
DEBUGGER    : 'debugger';
DEFAULT     : 'default';
DELETE      : 'delete';
DO          : 'do';
ELSE        : 'else';
EXPORT      : 'export';
EXTENDS     : 'extends';
FINALLY     : 'finally';
FOR         : 'for';
FUNCTION    : 'function';
IF          : 'if';
IMPORT      : 'import';
IN          : 'in';
INSTANCEOF  : 'instanceof';
NEW         : 'new';
RETURN      : 'return';
SUPER       : 'super';
SWITCH      : 'switch';
THIS        : 'this';
THROW       : 'throw';
TRY         : 'try';
TYPEOF      : 'typeof';
VAR         : 'var';
VOID        : 'void';
WHILE       : 'while';
WITH        : 'with';
YIELD       : 'yield';
LET         : 'let';
STATIC      : 'static';
ENUM        : 'enum';
AWAIT       : 'await';
ASYNC       : 'async';
OF          : 'of';

// ==========================================
// 2. Boolean and Null
// ==========================================

TRUE        : 'true';
FALSE       : 'false';
NULL        : 'null';

// ==========================================
// 3. Numbers
// ==========================================

BIGINT
    : (HEX_LITERAL | BINARY_LITERAL | OCTAL_LITERAL | DECIMAL_INTEGER) 'n'
    ;

HEX_NUMBER
    : HEX_LITERAL
    ;

OCTAL_NUMBER
    : OCTAL_LITERAL
    ;

BINARY_NUMBER
    : BINARY_LITERAL
    ;

FLOAT
    : DECIMAL_INTEGER '.' [0-9]* EXPONENT?
    | '.' [0-9]+ EXPONENT?
    | DECIMAL_INTEGER EXPONENT
    ;

INTEGER
    : DECIMAL_INTEGER
    ;

// ==========================================
// 4. Strings
// ==========================================

STRING
    : '"' (ESCAPE_SEQUENCE | ~["\\\r\n])* '"'
    | '\'' (ESCAPE_SEQUENCE | ~['\\\r\n])* '\''
    ;

// ==========================================
// 5. Template Literals
// ==========================================

TEMPLATE_LITERAL
    : '`' (ESCAPE_SEQUENCE | ~[`\\])* '`'
    ;

// ==========================================
// 6. Operators
// ==========================================

STRICT_EQUAL       : '===';
STRICT_NOT_EQUAL   : '!==';
EQUAL              : '==';
NOT_EQUAL          : '!=';
GREATER_EQUAL      : '>=';
LESS_EQUAL         : '<=';
INCREMENT          : '++';
DECREMENT          : '--';
POWER              : '**';
EXP_ASSIGN         : '**=';
PLUS_ASSIGN        : '+=';
MINUS_ASSIGN       : '-=';
MULT_ASSIGN        : '*=';
DIV_ASSIGN         : '/=';
MOD_ASSIGN         : '%=';
AND_ASSIGN         : '&&=';
OR_ASSIGN          : '||=';
NULLISH_ASSIGN     : '??=';
LEFT_SHIFT_ASSIGN  : '<<=';
RIGHT_SHIFT_ASSIGN : '>>=';
UNSIGNED_SHIFT_ASSIGN : '>>>=';
LEFT_SHIFT         : '<<';
RIGHT_SHIFT        : '>>';
UNSIGNED_SHIFT     : '>>>';
LOGICAL_AND        : '&&';
LOGICAL_OR         : '||';
NULLISH            : '??';
OPTIONAL_CHAIN     : '?.';
ARROW              : '=>';

PLUS               : '+';
MINUS              : '-';
MULT               : '*';
DIV                : '/';
MOD                : '%';
ASSIGN             : '=';
GREATER            : '>';
LESS               : '<';
NOT                : '!';
BIT_AND            : '&';
BIT_OR             : '|';
BIT_XOR            : '^';
BIT_NOT            : '~';
QUESTION           : '?';
COLON              : ':';

// ==========================================
// 7. Punctuation
// ==========================================

LPAREN       : '(';
RPAREN       : ')';
LBRACE       : '{';
RBRACE       : '}';
LBRACKET     : '[';
RBRACKET     : ']';
SEMICOLON    : ';';
COMMA        : ',';
DOT          : '.';

// ==========================================
// 8. Identifiers
// ==========================================

IDENTIFIER
    : ID_START ID_PART*
    ;

// ==========================================
// 9. Comments
// ==========================================

SINGLE_LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;

MULTI_LINE_COMMENT
    : '/*' .*? '*/' -> skip
    ;

// ==========================================
// 10. Whitespace
// ==========================================

WS
    : [ \t\r\n\u000C]+ -> skip
    ;

// ==========================================
// 11. Invalid Characters
// ==========================================

INVALID_CHAR
    : .
    ;

// ==========================================
// Fragments
// ==========================================

fragment DECIMAL_INTEGER
    : '0'
    | [1-9] [0-9]*
    ;

fragment HEX_LITERAL
    : '0' [xX] HEX_DIGIT+
    ;

fragment BINARY_LITERAL
    : '0' [bB] [01]+
    ;

fragment OCTAL_LITERAL
    : '0' [oO] [0-7]+
    ;

fragment HEX_DIGIT
    : [0-9a-fA-F]
    ;

fragment EXPONENT
    : [eE] [+-]? [0-9]+
    ;

fragment ESCAPE_SEQUENCE
    : '\\' .
    | '\\' '\r'? '\n'
    ;

fragment ID_START
    : [a-zA-Z_$]
    ;

fragment ID_PART
    : [a-zA-Z0-9_$]
    ;
