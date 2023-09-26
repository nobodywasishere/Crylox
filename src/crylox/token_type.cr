module Crylox
  enum TokenType : Int32
    # Single-character tokens
    LEFT_PAREN
    RIGHT_PAREN
    LEFT_BRACE
    RIGHT_BRACE
    COMMA
    DOT
    MINUS
    PLUS
    SEMICOLON
    SLASH
    STAR

    # One or two character tokens
    BANG
    BANG_EQUAL
    EQUAL
    EQUAL_EQUAL
    GREATER
    GREATER_EQUAL
    LESS
    LESS_EQUAL

    # Literals
    IDENTIFIER
    STRING
    NUMBER
    COMMENT

    # Keywords
    AND
    CLASS
    ELSE
    FALSE
    FUN
    FOR
    IF
    NIL
    OR
    PRINT
    RETURN
    SUPER
    THIS
    TRUE
    VAR
    WHILE

    # Add-on keywords
    NAND
    NOR
    XOR
    XNOR
    BREAK
    NEXT
    MODULUS
    LAMBDA
    MINUS_GREATER # ->

    PLUS_EQUAL
    MINUS_EQUAL
    SLASH_EQUAL
    STAR_EQUAL
    MOD_EQUAL

    TYPE

    ERROR
    EOF
  end
end
