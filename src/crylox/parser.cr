class Crylox::Parser
  class ParseError < Exception
    def initialize(message : String, token : Token)
      super("   #{" " * (token.col - 1)}^\n[line #{token.line}, col #{token.col}] ParseError: #{message}")
    end
  end

  property stdout : IO = STDOUT
  property stderr : IO = STDERR

  def initialize(@tokens : Array(Token))
    @current = 0
  end

  def parse : Array(Stmt)
    statements = [] of Stmt

    until at_end?
      stmt = declaration_stmt
      statements << stmt unless stmt.nil?
    end

    statements
  end

  private def statement : Stmt
    return for_stmt if match(TokenType::FOR)
    return if_stmt if match(TokenType::IF)
    return print_stmt if match(TokenType::PRINT)
    return return_stmt if match(TokenType::RETURN)
    return while_stmt if match(TokenType::WHILE)
    return break_stmt if match(TokenType::BREAK)
    return Stmt::Block.new(block_stmt) if match(TokenType::LEFT_BRACE)
    expression_stmt
  end

  private def expression : Expr
    assignment
  end

  # Statement parsers

  private def declaration_stmt : Stmt?
    return function_stmt("function") if match(TokenType::FUN)
    return var_declaration if match(TokenType::VAR)
    statement
  rescue ex : ParseError
    synchronize
  end

  private def for_stmt : Stmt::Block | Stmt::While
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'for'.")

    initializer : Stmt? = nil
    if match(TokenType::SEMICOLON)
      initializer = nil
    elsif match(TokenType::VAR)
      initializer = var_declaration
    else
      initializer = expression_stmt
    end

    condition : Expr? = nil
    unless check(TokenType::SEMICOLON)
      condition = expression
    end
    consume(TokenType::SEMICOLON, "Expect ';' after loop condition.")

    increment : Expr? = nil
    unless check(TokenType::RIGHT_PAREN)
      increment = expression
    end
    consume(TokenType::RIGHT_PAREN, "Expect ')' after for clauses.")

    body = statement

    unless increment.nil?
      body = Stmt::Block.new([body, Stmt::Expression.new(increment)])
    end

    if condition.nil?
      condition = Expr::Literal.new(true)
    end
    body = Stmt::While.new(condition, body)

    unless initializer.nil?
      body = Stmt::Block.new([initializer, body])
    end

    body
  end

  private def if_stmt : Stmt::If
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'if'.")
    condition = expression
    consume(TokenType::RIGHT_PAREN, "Expect ')' after if condition.")

    then_branch = statement
    else_branch = match(TokenType::ELSE) ? statement : nil

    Stmt::If.new(condition, then_branch, else_branch)
  end

  private def print_stmt : Stmt::Print
    value = expression
    consume(TokenType::SEMICOLON, "Expected ';' after value.")
    Stmt::Print.new(value)
  end

  private def return_stmt : Stmt::Return
    keyword = previous

    value = Expr::Literal.new(nil)
    unless check(TokenType::SEMICOLON)
      value = expression
    end

    consume(TokenType::SEMICOLON, "Expect ';' after return value.")
    Stmt::Return.new(keyword, value)
  end

  private def while_stmt : Stmt::While
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'while'.")
    condition = expression
    consume(TokenType::RIGHT_PAREN, "Expect ')' after while condition.")

    body = statement

    Stmt::While.new(condition, body)
  end

  private def break_stmt : Stmt::Break
    br = Stmt::Break.new(previous)
    consume(TokenType::SEMICOLON, "Expected ';' after break.")
    br
  end

  private def next_stmt : Stmt::Next
    nx = Stmt::Next.new(previous)
    consume(TokenType::SEMICOLON, "Expected ';' after next.")
    nx
  end

  private def var_declaration : Stmt::Var
    name = consume(TokenType::IDENTIFIER, "Expect variable name.")
    initializer = nil

    if match(TokenType::EQUAL)
      initializer = expression
    elsif match(TokenType::PLUS_EQUAL, TokenType::MINUS_EQUAL, TokenType::SLASH_EQUAL, TokenType::STAR_EQUAL, TokenType::MOD_EQUAL)
      initializer = equal_assignment(Expr::Variable.new(name), previous)
    end

    consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")

    Stmt::Var.new(name, initializer)
  end

  private def expression_stmt : Stmt::Expression
    expr = expression
    unless expr.is_a? Expr::Comment
      consume(TokenType::SEMICOLON, "Expected ';' after expression.")
    end
    Stmt::Expression.new(expr)
  end

  private def function_stmt(kind : String) : Stmt::Function
    name = consume(TokenType::IDENTIFIER, "Expect #{kind} name.")

    consume(TokenType::LEFT_PAREN, "Expect '(' after #{kind} name")
    parameters = [] of Token

    unless check(TokenType::RIGHT_PAREN)
      parameters << consume(TokenType::IDENTIFIER, "Expect parameter name.")
      while match(TokenType::COMMA)
        error("Cannot have more than 255 parameters.", peek) if parameters.size >= 255
        parameters << consume(TokenType::IDENTIFIER, "Expect parameter name.")
      end
    end
    consume(TokenType::RIGHT_PAREN, "Expect ')' after parameters.")
    consume(TokenType::LEFT_BRACE, "Expect '{' before #{kind} body.")
    body = block_stmt

    Stmt::Function.new(name, parameters, body)
  end

  private def block_stmt : Array(Stmt)
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
    expr = logical

    if match(TokenType::EQUAL, TokenType::PLUS_EQUAL, TokenType::MINUS_EQUAL, TokenType::SLASH_EQUAL, TokenType::STAR_EQUAL, TokenType::MOD_EQUAL)
      equals = previous

      if equals.type == TokenType::EQUAL
        value = assignment
      else
        value = equal_assignment(expr, equals)
      end

      if expr.is_a? Expr::Variable
        return Expr::Assign.new(expr.name, value)
      end

      raise error("Invalid assignment target.", equals)
    end

    expr
  end

  private def equal_assignment(name : Expr, equals : Token) : Expr
    type = case equals.type
           when .plus_equal?
             TokenType::PLUS
           when .minus_equal?
             TokenType::MINUS
           when .star_equal?
             TokenType::STAR
           when .slash_equal?
             TokenType::SLASH
           when .mod_equal?
             TokenType::MODULUS
           else
             raise error("Unknown equals assignment operator.", equals)
           end

    operator = Token.new(type, equals.lexeme[0..-2], equals.literal, equals.line, equals.col)

    Expr::Binary.new(name, operator, logical)
  end

  private def logical : Expr
    expr = equality

    while match(TokenType::AND, TokenType::OR, TokenType::NAND, TokenType::NOR, TokenType::XOR, TokenType::XNOR)
      operator = previous
      right = logical
      expr = Expr::Logical.new(expr, operator, right)
    end

    expr
  end

  private def equality : Expr
    expr = comparison

    while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  private def comparison : Expr
    expr = term

    while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  private def term : Expr
    expr = factor

    while match(TokenType::MINUS, TokenType::PLUS)
      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  private def factor : Expr
    expr = unary

    while match(TokenType::SLASH, TokenType::STAR, TokenType::MODULUS)
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  private def unary : Expr
    if match(TokenType::BANG, TokenType::MINUS)
      operator = previous
      right = unary
      return Expr::Unary.new(operator, right)
    end

    call
  end

  private def call
    expr = lambda

    loop do
      if match(TokenType::LEFT_PAREN)
        expr = finish_call(expr)
      else
        break
      end
    end

    expr
  end

  private def lambda : Expr
    if match(TokenType::LAMBDA, TokenType::MINUS_GREATER)
      consume(TokenType::LEFT_PAREN, "Expect '(' after lambda")
      parameters = [] of Token

      unless check(TokenType::RIGHT_PAREN)
        parameters << consume(TokenType::IDENTIFIER, "Expect parameter name.")
        while match(TokenType::COMMA)
          error("Cannot have more than 255 parameters.", peek) if parameters.size >= 255
          parameters << consume(TokenType::IDENTIFIER, "Expect parameter name.")
        end
      end
      consume(TokenType::RIGHT_PAREN, "Expect ')' after parameters.")
      consume(TokenType::LEFT_BRACE, "Expect '{' before lambda body.")
      body = block_stmt

      return Expr::Lambda.new(parameters, body)
    end

    primary
  end

  private def finish_call(callee : Expr) : Expr
    arguments = [] of Expr

    unless check(TokenType::RIGHT_PAREN)
      arguments << expression

      while match(TokenType::COMMA)
        error("Cannot have more than 255 arguments.", peek) if arguments.size >= 255
        arguments << expression
      end
    end

    paren = consume(TokenType::RIGHT_PAREN, "Expect ')' after arguments.")

    Expr::Call.new(callee, paren, arguments)
  end

  private def primary : Expr
    return Expr::Literal.new(false) if match(TokenType::FALSE)
    return Expr::Literal.new(true) if match(TokenType::TRUE)
    return Expr::Literal.new(nil) if match(TokenType::NIL)
    return Expr::Literal.new(previous.literal) if match(TokenType::NUMBER, TokenType::STRING)

    return Expr::Variable.new(previous) if match(TokenType::IDENTIFIER)
    return Expr::Comment.new(previous) if match(TokenType::COMMENT)

    if match(TokenType::LEFT_PAREN)
      expr = expression
      consume(TokenType::RIGHT_PAREN, "Expected ')' after expression.")
      return Expr::Grouping.new(expr)
    end

    raise error("Expected expression.", peek)
  end

  # Helper methods

  private def match(*types : TokenType) : Bool
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
      return advance
    end

    raise error(message, peek)
  end

  private def check(type : TokenType) : Bool
    return false if at_end?
    peek.type == type
  end

  private def advance : Token
    @current += 1 unless at_end?
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
    ex = ParseError.new message, token
    stderr.puts ex
    ex
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
