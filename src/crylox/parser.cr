class Crylox::Parser
  Log = ::Log.for(self)

  class ParseError < Exception
    def initialize(message : String, token : Token)
      super("  #{" " * (token.col - 1)}^\n[line #{token.line}, col #{token.col}]: #{message}")
    end
  end

  def initialize(@tokens : Array(Token))
    @current = 0
  end

  def parse : Array(Stmt)
    Log.debug { "Parsing tokens" }
    statements = [] of Stmt

    until at_end?
      Log.debug { "token: #{peek.lexeme}, at_end?: #{at_end?}" }
      stmt = declaration_stmt
      statements << stmt unless stmt.nil?
    end

    statements
  rescue ParseError
    return [] of Stmt
  end

  private def statement : Stmt
    return print_stmt if match(TokenType::PRINT)
    return Stmt::Block.new(block_stmt) if match(TokenType::LEFT_BRACE)
    expression_stmt
  end

  private def expression : Expr
    Log.debug { "Parsing expression" }

    assignment
  end

  # Statement parsers

  private def declaration_stmt : Stmt?
    return var_declaration if match(TokenType::VAR)
    statement
  rescue ex : ParseError
    puts ex

    synchronize

    nil
  end

  private def print_stmt : Stmt::Print
    Log.debug { "Parsing print stmt" }

    value = expression
    consume(TokenType::SEMICOLON, "Expected ';' after value.")
    Stmt::Print.new(value)
  end

  private def var_declaration : Stmt::Var
    name = consume(TokenType::IDENTIFIER, "Expect variable name.")
    initializer = nil

    if match(TokenType::EQUAL)
      initializer = expression
    end

    consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")
    return Stmt::Var.new(name, initializer)
  end

  private def expression_stmt : Stmt::Expression
    Log.debug { "Parsing expression stmt" }

    expr = expression
    consume(TokenType::SEMICOLON, "Expected ';' after expression.")
    Stmt::Expression.new(expr)
  end

  private def block_stmt
    statements = [] of Stmt

    until check(TokenType::RIGHT_BRACE) || at_end?
      stmt = declaration_stmt
      statements << stmt unless stmt.nil?
    end

    consume(TokenType::RIGHT_BRACE, "Expect '}' after block.")

    statements
  end

  # Expression parsers

  private def assignment : Expr
    expr = equality

    if match(TokenType::EQUAL)
      equals = previous

      value = assignment

      if expr.is_a? Expr::Variable
        return Expr::Assign.new(expr.name, value)
      end

      error("Invalid assignment target.", equals)
    end

    expr
  end

  private def equality : Expr
    Log.debug { "Parsing equality" }

    expr = comparison

    while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
      Log.debug { "Matched equality on #{previous.lexeme}" }

      operator = previous
      right = comparison
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  private def comparison : Expr
    Log.debug { "Parsing comparison" }

    expr = term

    while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
      Log.debug { "Matched comparison on #{previous.lexeme}" }

      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  private def term : Expr
    Log.debug { "Parsing term" }

    expr = factor

    while match(TokenType::MINUS, TokenType::PLUS)
      Log.debug { "Matched term on #{previous.lexeme}" }

      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  private def factor : Expr
    Log.debug { "Parsing factor" }

    expr = unary

    while match(TokenType::SLASH, TokenType::STAR)
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  private def unary : Expr
    Log.debug { "Parsing unary" }

    if match(TokenType::BANG, TokenType::MINUS)
      Log.debug { "Matched unary on #{previous.lexeme}" }

      operator = previous
      right = unary
      return Expr::Unary.new(operator, right)
    end

    primary
  end

  private def primary : Expr
    Log.debug { "Parsing primary" }

    if match(TokenType::FALSE)
      Log.debug { "Matched false on #{previous.type} (#{previous.lexeme})" }
      return Expr::Literal.new(false)
    end

    if match(TokenType::TRUE)
      Log.debug { "Matched true on #{previous.lexeme}" }
      return Expr::Literal.new(true)
    end

    if match(TokenType::NIL)
      Log.debug { "Matched nil on #{previous.lexeme}" }
      return Expr::Literal.new(nil)
    end

    if match(TokenType::NUMBER, TokenType::STRING)
      Log.debug { "Matched number, string on #{previous.lexeme}" }
      return Expr::Literal.new(previous.literal)
    end

    if match(TokenType::IDENTIFIER)
      return Expr::Variable.new(previous)
    end

    if match(TokenType::LEFT_PAREN)
      Log.debug { "Matched ( on #{previous.lexeme}" }

      expr = expression
      consume(TokenType::RIGHT_PAREN, "Expected ')' after expression.")
      return Expr::Grouping.new(expr)
    end

    error("Expected expression.", peek)
  end

  # Helper methods

  private def match(*types : TokenType) : Bool
    Log.debug { "Matching #{types} to #{peek.type}" }
    types.each do |type|
      if check(type)
        advance
        return true
      end
    end

    false
  end

  private def consume(type : TokenType, message : String) : Token
    if check(type)
      Log.debug { "Consuming #{peek} for #{type}" }
      return advance
    end

    error(message, peek)
  end

  private def check(type : TokenType) : Bool
    return false if at_end?
    Log.debug { "Checking #{peek.type} for #{type}: #{peek.type == type}" }
    peek.type == type
  end

  private def advance : Token
    @current += 1 unless at_end?
    Log.debug { "Advancing to #{@current}: #{@tokens[@current].lexeme}" }
    previous
  end

  private def at_end? : Bool
    peek.type.eof?
  end

  private def peek : Token
    @tokens[@current]
  end

  private def previous : Token
    @tokens[@current - 1]
  end

  private def error(message : String, token : Token) : ParseError
    raise ParseError.new message, token
  end

  private def synchronize : Nil
    advance

    until at_end?
      return if previous.type.semicolon?

      case peek.type
      when .class?, .for?, .fun?, .if?, .print?, .return?, .var?, .while?
        return
      end

      advance
    end
  end
end
