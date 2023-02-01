require "./Expr"
require "./Token"
require "./TokenTypes"

module Crylox::Parser
  class ParseError < Exception
    def initialize(message : String | Nil = nil, cause : Exception | Nil = nil, token : Token | Nil = nil)
      Crylox.new().error(token, message)
      super(message, cause)
    end
  end

  class Parser
    @tokens : Array(Token)
    @current : Int32 = 0

    def initialize(tokens : Array(Token))
      @tokens = tokens
    end

    def parse() : Expr::Expr | Nil
      begin
        return expression()
      rescue ParseError
        return nil
      end
    end

    private def expression() : Expr::Expr
      return equality()
    end

    private def equality() : Expr::Expr
      expr : Expr::Expr = comparison()
      while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
        operator : Token = previous()
        right : Expr::Expr = comparison()
        expr = Expr::Binary.new(expr, operator, right)
      end
      return expr
    end

    private def comparison() : Expr::Expr
      expr : Expr::Expr = term()
      while match(TokenType::GREATER, TokenType::GREATER_EQUAL,
        TokenType::LESS, TokenType::LESS_EQUAL)
        operator : Token = previous()
        right : Expr::Expr = term()
        expr = Expr::Binary.new(expr, operator, right)
      end
      return expr
    end

    private def term() : Expr::Expr
      expr : Expr::Expr = factor()
      while match(TokenType::MINUS, TokenType::PLUS)
        operator : Token = previous()
        right : Expr::Expr = factor()
        expr = Expr::Binary.new(expr, operator, right)
      end
      return expr
    end

    private def factor() : Expr::Expr
      expr : Expr::Expr = unary()
      while match(TokenType::SLASH, TokenType::STAR)
        operator : Token = previous()
        right : Expr::Expr = unary()
        expr = Expr::Binary.new(expr, operator, right)
      end
      return expr
    end

    private def unary() : Expr::Expr
      if match(TokenType::BANG, TokenType::MINUS)
        operator : Token = previous()
        right : Expr::Expr = unary()
        return Expr::Unary.new(operator, right)
      end
      return primary()
    end

    private def primary() : Expr::Expr
      return Expr::Literal.new(false) if match(TokenType::FALSE)
      return Expr::Literal.new(true) if match(TokenType::TRUE)
      return Expr::Literal.new(nil) if match(TokenType::NIL)
      return Expr::Literal.new(previous().literal()) if match(TokenType::NUMBER, TokenType::STRING)

      if match(TokenType::LEFT_PAREN)
        expr : Expr::Expr = expression()
        consume(TokenType::RIGHT_PAREN, "Expect ')' after expression.")
        return Expr::Grouping.new(expr)
      end

      raise parse_error(peek(), "Expected expression.")
    end

    private def match(*types) : Bool
      types.each do |type|
        if check(type)
          advance()
          return true
        end
      end
      return false
    end

    private def consume(type : TokenType, message : String) : Token
      return advance() if check(type)
      raise parse_error(peek(), message)
    end

    private def check(type : TokenType) : Bool
      return false if at_end?
      return peek().type == type
    end

    private def advance() : Token
      @current += 1 if !at_end?
      return previous()
    end

    private def at_end?
      return peek().type == TokenType::EOF
    end

    private def peek() : Token
      return @tokens[@current]
    end

    private def previous() : Token
      return @tokens[@current-1]
    end

    private def parse_error(token : Token, message : String)
      Crylox.new().error(token, message)
      return ParseError.new(message, nil, token)
    end

    private def synchronize() : Nil
      advance()
      while !at_end?
        return if previous().type == TokenType::SEMICOLON

        case peek().type
        when TokenType::CLASS | TokenType::FOR | TokenType::FUN | TokenType::IF | TokenType::PRINT | TokenType::RETURN | TokenType::VAR | TokenType::WHILE
          return
        end

        advance()
      end
    end

  end
end
