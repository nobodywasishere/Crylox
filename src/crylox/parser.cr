class Crylox::Parser
  Log = ::Log.for(self)

  class ParseError < Exception; end

  def initialize(@tokens : Array(Token))
    @current = 0
  end

  def parse : Expr?
    Log.debug { "Parsing tokens" }
    expression
  rescue ParseError
    return nil
  end

  private def expression : Expr
    Log.debug { "Parsing expression" }

    equality
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

    if match(TokenType::LEFT_PAREN)
      Log.debug { "Matched ( on #{previous.lexeme}" }

      expr = expression
      consume(TokenType::RIGHT_PAREN, "Expected ')' after expression.")
      return Expr::Grouping.new(expr)
    end

    raise error("Expected expression.", peek)
  end

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
    return advance if check(type)

    raise error(message, peek)
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
    peek.type == :eof
  end

  private def peek : Token
    @tokens[@current]
  end

  private def previous : Token
    @tokens[@current - 1]
  end

  private def error(message : String, token : Token) : ParseError
    Log.error &.emit(message, line: token.line, col: token.col)
    ParseError.new "[line #{token.line}, col #{token.col}]: #{message}"
  end

  private def synchronize : Nil
    advance

    until at_end?
      return if previous.type == :semicolon

      case peek.type
      when .class?, .for?, .fun?, .if?, .print?, .return?, .var?, .while?
        return
      end

      advance
    end
  end
end
