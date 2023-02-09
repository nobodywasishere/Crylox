require "./Expr"
require "./Stmt"
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

    def parse() : Array(Stmt::Stmt | Nil) | Nil
      statements = [] of Stmt::Stmt | Nil
      while !at_end?
        statements << declaration()
      end
      return statements
    end

    private def expression() : Expr::Expr
      return assignment()
    end

    private def declaration() : Stmt::Stmt | Nil
      begin
        return varDeclaration() if match(TokenType::VAR)
        return statement()
      rescue e : ParseError
        synchronize()
        return nil
      end
    end

    private def statement() : Stmt::Stmt
      return printStatement() if match(TokenType::PRINT)
      return Stmt::Block.new(block()) if match(TokenType::LEFT_BRACE)
      return expressionStatement()
    end

    private def printStatement() : Stmt::Stmt
      value : Expr::Expr = expression()
      consume(TokenType::SEMICOLON, "Expected ';' after value.")
      return Stmt::Print.new(value)
    end

    private def varDeclaration() : Stmt::Stmt
      name : Token = consume(TokenType::IDENTIFIER, "Expected variable name.")

      initializer : Expr::Expr | Nil = nil
      if match(TokenType::EQUAL)
        initializer = expression()
      end

      consume(TokenType::SEMICOLON, "Expected ';' after variable declaration")
      return Stmt::Var.new(name, initializer)
    end

    private def expressionStatement() : Stmt::Stmt
      expr : Expr::Expr = expression()
      consume(TokenType::SEMICOLON, "Expect ';' after expression.")
      return Stmt::Expression.new(expr)
    end

    private def block() : Array(Stmt::Stmt)
      statements = [] of Stmt::Stmt
      while (!check(TokenType::RIGHT_BRACE) && !at_end?)
        dec = declaration()
        statements << dec if !dec.nil?
      end

      consume(TokenType::RIGHT_BRACE, "Expected '}' after block.")
      return statements;
    end

    private def assignment() : Expr::Expr
      expr : Expr::Expr = equality()

      if match(TokenType::EQUAL)
        equals : Token = previous()
        value : Expr::Expr = assignment()

        if expr.is_a? Expr::Variable
          name : Token = expr.name
          return Expr::Assign.new(name, value)
        end

        parse_error(equals, "Invalid assignment target.")
      end

      return expr
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
      return Expr::Variable.new(previous()) if match(TokenType::IDENTIFIER)

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
      if check(type)
        return advance()
      else
        raise parse_error(peek(), message)
      end
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
