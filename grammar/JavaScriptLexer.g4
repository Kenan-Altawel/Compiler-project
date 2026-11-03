
lexer grammar JavaScriptLexer;

// =====================================
// 1. Reserved Keywords
// =====================================

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
LET         : 'let';
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
ASYNC       : 'async';
AWAIT       : 'await';
OF          : 'of';

// =====================================
// 2. Boolean and Null
// =====================================

TRUE        : 'true';
FALSE       : 'false';
NULL        : 'null';

// =====================================
// 3. Numbers
// =====================================

// Integer
INTEGER
    : [0-9]+
    ;

// Float
FLOAT
    : [0-9]+ '.' [0-9]+
    ;

// Hexadecimal
HEX_NUMBER
    : '0' [xX] [0-9a-fA-F]+
    ;

// Octal
OCTAL_NUMBER
    : '0' [oO] [0-7]+
    ;

// Binary
BINARY_NUMBER
    : '0' [bB] [01]+
    ;

// BigInt
BIGINT
    : ([0-9]+ | '0' [xX] [0-9a-fA-F]+) 'n'
    ;

// =====================================
// 4. String Literals
// =====================================

STRING
    : '"' (ESCAPE_SEQUENCE | ~["\\\r\n])* '"'
    | '\'' (ESCAPE_SEQUENCE | ~['\\\r\n])* '\''
    ;

fragment ESCAPE_SEQUENCE
    : '\\' .
    ;

// =====================================
// 5. Template Literals
// =====================================

TEMPLATE_LITERAL
    : '`' .*? '`'
    ;

// =====================================
// 6. Identifiers
// =====================================

IDENTIFIER
    : [a-zA-Z_$] [a-zA-Z0-9_$]*
    ;

// =====================================
// 7. Operators
// =====================================

STRICT_EQUAL     : '===';
STRICT_NOT_EQUAL : '!==';

INCREMENT        : '++';
DECREMENT        : '--';

ARROW            : '=>';

PLUS_ASSIGN      : '+=';
MINUS_ASSIGN     : '-=';
MULT_ASSIGN      : '*=';
DIV_ASSIGN       : '/=';

AND              : '&&';
OR               : '||';
NOT              : '!';

EQUAL            : '==';
NOT_EQUAL        : '!=';

LESS_EQUAL       : '<=';
GREATER_EQUAL    : '>=';

PLUS             : '+';
MINUS            : '-';
MULT             : '*';
DIV              : '/';
MOD              : '%';

ASSIGN           : '=';
LESS             : '<';
GREATER          : '>';

QUESTION         : '?';
OPTIONAL_CHAIN   : '?.';
NULLISH          : '??';

// =====================================
// 8. Punctuation
// =====================================

DOT              : '.';
COMMA            : ',';
SEMICOLON        : ';';
COLON            : ':';

LPAREN           : '(';
RPAREN           : ')';

LBRACE           : '{';
RBRACE           : '}';

LBRACK           : '[';
RBRACK           : ']';

// =====================================
// 9. Comments
// =====================================

SINGLE_LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;

MULTI_LINE_COMMENT
    : '/*' .*? '*/' -> skip
    ;

// =====================================
// 10. Whitespace
// =====================================

WHITESPACE
    : [ \t\r\n]+ -> skip
    ;
