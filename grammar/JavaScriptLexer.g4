lexer grammar JavaScriptLexer;

tokens {
    DQ_STRING,
    SQ_STRING,
    REGEX_LITERAL,
    BLOCK_COMMENT,
    JSDOC_COMMENT,
    UNTERMINATED_STRING,
    UNTERMINATED_TEMPLATE,
    UNTERMINATED_COMMENT,
    UNTERMINATED_REGEX,
    INVALID_ESCAPE,
    TEMPLATE_EXPR_END
}

channels {
    COMMENTS,
    ERRORS
}

@members {
    private final java.util.Deque<Integer> templateExpressionBraceDepths =
        new java.util.ArrayDeque<Integer>();
    private final java.util.Deque<Boolean> controlParentheses =
        new java.util.ArrayDeque<Boolean>();
    private boolean regexAllowed = true;
    private boolean controlParenClosed;
    private int lastSignificantTokenType = Token.INVALID_TYPE;
    private org.antlr.v4.runtime.Token pendingErrorToken;

    @Override
    public org.antlr.v4.runtime.Token nextToken() {
        if (pendingErrorToken != null) {
            org.antlr.v4.runtime.Token token = pendingErrorToken;
            pendingErrorToken = null;
            return token;
        }
        return super.nextToken();
    }

    private void queueUnterminatedTemplateError() {
        if (_input.LA(1) != org.antlr.v4.runtime.IntStream.EOF
                || _mode != DEFAULT_MODE
                || templateExpressionBraceDepths.isEmpty()) {
            return;
        }

        reportLexicalError("Unterminated template expression", 0);
        org.antlr.v4.runtime.CommonToken error =
            new org.antlr.v4.runtime.CommonToken(UNTERMINATED_TEMPLATE, "");
        error.setChannel(ERRORS);
        error.setLine(getLine());
        error.setCharPositionInLine(getCharPositionInLine());
        error.setStartIndex(_input.index());
        error.setStopIndex(_input.index() - 1);
        pendingErrorToken = error;
        templateExpressionBraceDepths.clear();
        controlParentheses.clear();
        _modeStack.clear();
        mode(DEFAULT_MODE);
    }

    private void reportLexicalError(String message, int width) {
        int column = Math.max(0, getCharPositionInLine() - width);
        getErrorListenerDispatch().syntaxError(
            this, null, getLine(), column, message, null
        );
    }

    @Override
    public org.antlr.v4.runtime.Token emit() {
        org.antlr.v4.runtime.Token token = super.emit();
        if (token.getChannel() != org.antlr.v4.runtime.Token.DEFAULT_CHANNEL) {
            return token;
        }

        if (token.getType() == RPAREN) {
            regexAllowed = controlParenClosed;
            controlParenClosed = false;
            lastSignificantTokenType = token.getType();
            queueUnterminatedTemplateError();
            return token;
        }

        switch (token.getType()) {
            case IDENTIFIER:
            case INTEGER:
            case FLOAT:
            case BIGINT:
            case HEX_NUMBER:
            case OCTAL_NUMBER:
            case BINARY_NUMBER:
            case DQ_STRING:
            case SQ_STRING:
            case TRUE:
            case FALSE:
            case NULL:
            case THIS:
            case SUPER:
            case REGEX_LITERAL:
            case TEMPLATE_END:
            case RBRACKET:
            case RBRACE:
            case TEMPLATE_EXPR_END:
            case INCREMENT:
            case DECREMENT:
                regexAllowed = false;
                break;
            default:
                regexAllowed = true;
                break;
        }
        lastSignificantTokenType = token.getType();
        queueUnterminatedTemplateError();
        return token;
    }
}

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
// 2. Boolean, null, and numeric literals
// ==========================================

TRUE        : 'true';
FALSE       : 'false';
NULL        : 'null';

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
// 3. Quoted strings
// ==========================================

DQ_STRING_START
    : '"' -> more, pushMode(DQ_STRING_MODE)
    ;

SQ_STRING_START
    : '\'' -> more, pushMode(SQ_STRING_MODE)
    ;

// ==========================================
// 4. Template literals
// ==========================================

TEMPLATE_START
    : '`' -> pushMode(TEMPLATE_MODE)
    ;

// ==========================================
// 5. Operators
// ==========================================

STRICT_EQUAL       : '===';
STRICT_NOT_EQUAL   : '!==';
EQUAL              : '==';
NOT_EQUAL          : '!=';
GREATER_EQUAL      : '>=';
LESS_EQUAL         : '<=';
INCREMENT          : '++';
DECREMENT          : '--';
EXP_ASSIGN         : '**=';
POWER              : '**';
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
BIT_AND_ASSIGN     : '&=';
BIT_OR_ASSIGN      : '|=';
BIT_XOR_ASSIGN     : '^=';

PLUS               : '+';
MINUS              : '-';
MULT               : '*';
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

REGEX_START
    : {regexAllowed}? '/' -> more, pushMode(REGEX_MODE)
    ;

DIV
    : '/'
    ;

// ==========================================
// 6. Punctuation and identifiers
// ==========================================

LPAREN       : '(' {
    controlParentheses.push(
        lastSignificantTokenType == IF
        || lastSignificantTokenType == WHILE
        || lastSignificantTokenType == FOR
        || lastSignificantTokenType == WITH
        || lastSignificantTokenType == SWITCH
        || lastSignificantTokenType == CATCH
    );
};
RPAREN       : ')' {
    controlParenClosed =
        !controlParentheses.isEmpty() && controlParentheses.pop();
};
LBRACE       : '{' {
    if (!templateExpressionBraceDepths.isEmpty()) {
        int depth = templateExpressionBraceDepths.pop();
        templateExpressionBraceDepths.push(depth + 1);
    }
};
RBRACE       : '}' {
    if (!templateExpressionBraceDepths.isEmpty()) {
        int depth = templateExpressionBraceDepths.pop();
        if (depth == 0) {
            setType(TEMPLATE_EXPR_END);
            popMode();
        } else {
            templateExpressionBraceDepths.push(depth - 1);
        }
    }
};
LBRACKET     : '[';
RBRACKET     : ']';
SEMICOLON    : ';';
COMMA        : ',';
ELLIPSIS     : '...';
DOT          : '.';

IDENTIFIER
    : ID_START ID_PART*
    ;

// ==========================================
// 7. Comments
// ==========================================

EMPTY_JSDOC
    : '/**/' -> type(JSDOC_COMMENT), channel(COMMENTS)
    ;

JSDOC_START
    : '/**' -> more, pushMode(JSDOC_MODE)
    ;

BLOCK_COMMENT_START
    : '/*' -> more, pushMode(BLOCK_COMMENT_MODE)
    ;

SINGLE_LINE_COMMENT
    : '//' ~[\r\n\u2028\u2029]* -> channel(COMMENTS)
    ;

// ==========================================
// 8. Whitespace
// ==========================================

WS
    : [ \t\r\n\u000C\u2028\u2029]+ {
        if (_input.LA(1) == org.antlr.v4.runtime.IntStream.EOF
                && !templateExpressionBraceDepths.isEmpty()) {
            setType(UNTERMINATED_TEMPLATE);
            setChannel(ERRORS);
            reportLexicalError("Unterminated template expression", 0);
            templateExpressionBraceDepths.clear();
            controlParentheses.clear();
            _modeStack.clear();
            mode(DEFAULT_MODE);
        } else {
            skip();
        }
      }
    ;

TEMPLATE_EXPR_EOF
    : EOF {
        if (!templateExpressionBraceDepths.isEmpty()) {
            setType(UNTERMINATED_TEMPLATE);
            setChannel(ERRORS);
            reportLexicalError("Unterminated template expression", 0);
            templateExpressionBraceDepths.clear();
            controlParentheses.clear();
            _modeStack.clear();
            mode(DEFAULT_MODE);
        } else {
            setType(org.antlr.v4.runtime.Token.EOF);
        }
      }
    ;

// ==========================================
// 9. Error recovery
// Keep this fallback last among the default-mode rules.
// ==========================================

INVALID_CHAR
    : . -> channel(ERRORS)
    ;

// ==========================================
// Shared fragments
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

fragment HEX_DIGIT_1_TO_6
    : HEX_DIGIT HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT?
    ;

fragment VALID_ESCAPE_SEQUENCE
    : '\\' (
        [btnvfr0\\'"`/$]
        | 'x' HEX_DIGIT HEX_DIGIT
        | 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
        | 'u{' HEX_DIGIT_1_TO_6 '}'
        | '\r'? '\n'
        | '\r'
        | '\u2028'
        | '\u2029'
    )
    ;

fragment ID_START
    : [a-zA-Z_$]
    ;

fragment ID_PART
    : [a-zA-Z0-9_$]
    ;

// ==========================================
// 10. String modes
// ==========================================

mode DQ_STRING_MODE;

DQ_STRING_END
    : '"' -> type(DQ_STRING), popMode
    ;

DQ_STRING_ESCAPE
    : VALID_ESCAPE_SEQUENCE -> more
    ;

DQ_STRING_INVALID_ESCAPE
    : '\\' ~[\r\n\u2028\u2029] {
        reportLexicalError("Invalid escape sequence in double-quoted string", 2);
      } -> more
    ;

DQ_STRING_DANGLING_ESCAPE
    : '\\' {
        reportLexicalError("Incomplete escape sequence in double-quoted string", 1);
      } -> more
    ;

DQ_STRING_LINE_TERMINATOR
    : (
        '\r'? '\n'
        | '\r'
        | '\u2028'
        | '\u2029'
      ) -> type(UNTERMINATED_STRING), channel(ERRORS), popMode
    ;

DQ_STRING_CHAR
    : ~["\\\r\n\u2028\u2029]+ -> more
    ;

DQ_STRING_EOF
    : EOF -> type(UNTERMINATED_STRING), channel(ERRORS), popMode
    ;

mode SQ_STRING_MODE;

SQ_STRING_END
    : '\'' -> type(SQ_STRING), popMode
    ;

SQ_STRING_ESCAPE
    : VALID_ESCAPE_SEQUENCE -> more
    ;

SQ_STRING_INVALID_ESCAPE
    : '\\' ~[\r\n\u2028\u2029] {
        reportLexicalError("Invalid escape sequence in single-quoted string", 2);
      } -> more
    ;

SQ_STRING_DANGLING_ESCAPE
    : '\\' {
        reportLexicalError("Incomplete escape sequence in single-quoted string", 1);
      } -> more
    ;

SQ_STRING_LINE_TERMINATOR
    : (
        '\r'? '\n'
        | '\r'
        | '\u2028'
        | '\u2029'
      ) -> type(UNTERMINATED_STRING), channel(ERRORS), popMode
    ;

SQ_STRING_CHAR
    : ~['\\\r\n\u2028\u2029]+ -> more
    ;

SQ_STRING_EOF
    : EOF -> type(UNTERMINATED_STRING), channel(ERRORS), popMode
    ;

// ==========================================
// Template mode and template-expression state
// ==========================================

mode TEMPLATE_MODE;

TEMPLATE_END
    : '`' -> popMode
    ;

TEMPLATE_EXPR_START
    : '${' {
        templateExpressionBraceDepths.push(0);
      } -> pushMode(DEFAULT_MODE)
    ;

TEMPLATE_ESCAPE
    : VALID_ESCAPE_SEQUENCE -> type(TEMPLATE_TEXT)
    ;

TEMPLATE_INVALID_ESCAPE
    : '\\' ~[\r\n\u2028\u2029] {
        reportLexicalError("Invalid escape sequence in template literal", 2);
      } -> type(INVALID_ESCAPE), channel(ERRORS)
    ;

TEMPLATE_DANGLING_ESCAPE
    : '\\' {
        reportLexicalError("Incomplete escape sequence in template literal", 1);
      } -> type(INVALID_ESCAPE), channel(ERRORS)
    ;

TEMPLATE_TEXT
    : ~[`\\$]+
    ;

TEMPLATE_EOF
    : EOF -> type(UNTERMINATED_TEMPLATE), channel(ERRORS), popMode
    ;

TEMPLATE_DOLLAR
    : '$' -> type(TEMPLATE_TEXT)
    ;

// ==========================================
// Block-comment and JSDoc modes
// ==========================================

mode BLOCK_COMMENT_MODE;

BLOCK_COMMENT_END
    : '*/' -> type(BLOCK_COMMENT), channel(COMMENTS), popMode
    ;

BLOCK_COMMENT_CHAR
    : . -> more
    ;

BLOCK_COMMENT_EOF
    : EOF -> type(UNTERMINATED_COMMENT), channel(ERRORS), popMode
    ;

mode JSDOC_MODE;

JSDOC_END
    : '*/' -> type(JSDOC_COMMENT), channel(COMMENTS), popMode
    ;

JSDOC_CHAR
    : . -> more
    ;

JSDOC_EOF
    : EOF -> type(UNTERMINATED_COMMENT), channel(ERRORS), popMode
    ;

// ==========================================
// Regular-expression and character-class modes
// ==========================================

mode REGEX_MODE;

REGEX_END
    : '/' [a-zA-Z]* -> type(REGEX_LITERAL), popMode
    ;

REGEX_CLASS_START
    : '[' -> more, pushMode(REGEX_CLASS_MODE)
    ;

REGEX_ESCAPE
    : '\\' ~[\r\n\u2028\u2029] -> more
    ;

REGEX_LINE_TERMINATOR
    : [\r\n\u2028\u2029] {
        reportLexicalError("Unterminated regular expression literal", 1);
        popMode();
      } -> type(UNTERMINATED_REGEX), channel(ERRORS)
    ;

REGEX_CHAR
    : . -> more
    ;

REGEX_EOF
    : EOF -> type(UNTERMINATED_REGEX), channel(ERRORS), popMode
    ;

mode REGEX_CLASS_MODE;

REGEX_CLASS_END
    : ']' -> more, popMode
    ;

REGEX_CLASS_ESCAPE
    : '\\' ~[\r\n\u2028\u2029] -> more
    ;

REGEX_CLASS_LINE_TERMINATOR
    : [\r\n\u2028\u2029] {
        reportLexicalError("Unterminated regular expression character class", 1);
        popMode();
        popMode();
      } -> type(UNTERMINATED_REGEX), channel(ERRORS)
    ;

REGEX_CLASS_CHAR
    : . -> more
    ;

REGEX_CLASS_EOF
    : EOF {
        popMode();
        popMode();
      } -> type(UNTERMINATED_REGEX), channel(ERRORS)
    ;
