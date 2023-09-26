class Crylox::Interpreter
  include Crylox::Expr::Visitor
  include Crylox::Stmt::Visitor

  class RuntimeError < Crylox::Exception; end

  class ReturnStmt < RuntimeError
    getter value : LiteralType

    def initialize(@message, @token, @value)
      super(message, token)
    end
  end

  class BreakStmt < RuntimeError; end

  class NextStmt < RuntimeError; end

  property globals : Crylox::Environment
  property env : Crylox::Environment
  property locals : Hash(Expr, Int32)
  property stdout : IO = STDOUT

  def initialize(@log : Crylox::Log)
    @globals = Crylox::Environment.new(@log)
    @env = globals
    @locals = {} of Expr => Int32

    define_native("clock", Crylox::Native::Clock.new)
    define_native("typeof", Crylox::Native::TypeOf.new)
  end

  def define_native(name : String, method : LoxCallable)
    globals.define(Token.new(TokenType::FUN, name, name, 0, 0), method)
  end

  def interpret(@log : Crylox::Log, statements : Array(Stmt)) : LiteralType
    last = nil

    statements.each do |stmt|
      last = execute(stmt)
    end

    last
  rescue ex : ReturnStmt
    error(ex.message || "", ex.token)
    nil
  end

  def execute(stmt : Stmt) : LiteralType
    stmt.accept(self)
  end

  def resolve(expr : Expr, depth : Int32)
    locals[expr] = depth
  end

  def evaluate(expr : Expr) : LiteralType
    expr.accept(self)
  end

  # Statements

  def visit_block(stmt : Stmt::Block) : LiteralType
    execute_block(stmt.statements, Environment.new(@log, env))
  end

  def execute_block(statements : Array(Stmt), env : Environment) : LiteralType
    previous_env = self.env
    self.env = env

    last = nil

    begin
      statements.each do |s|
        last = execute(s)
      end
    ensure
      self.env = previous_env
    end

    last
  end

  def visit_var(stmt : Stmt::Var) : LiteralType
    value = nil

    unless (init = stmt.initializer).nil?
      value = evaluate(init)
    end

    env.define(stmt.name, value)
  end

  def visit_assign(expr : Expr::Assign) : LiteralType
    value = evaluate(expr.value)

    distance = locals[expr]?
    if distance.nil?
      globals.assign(expr.name, value)
    else
      env.assign_at(expr.name, value, distance)
    end

    value
  end

  def visit_expression(stmt : Stmt::Expression) : LiteralType
    evaluate(stmt.expression)
  end

  def visit_function(stmt : Stmt::Function) : LiteralType
    function = LoxFunction.new(stmt, env, @log)
    env.define(stmt.name, function)
    function
  end

  def visit_if(stmt : Stmt::If) : Nil
    if evaluate(stmt.condition)
      execute(stmt.then_branch)
    elsif !(else_branch = stmt.else_branch).nil?
      execute(else_branch)
    end
  end

  def visit_while(stmt : Stmt::While) : Nil
    while evaluate(stmt.condition)
      begin
        execute(stmt.body)
      rescue BreakStmt | NextStmt
        break
      end
    end
  end

  def visit_return(stmt : Stmt::Return) : Nil
    raise ReturnStmt.new("return must be within a function", stmt.keyword, evaluate(stmt.value))
  end

  def visit_break(stmt : Stmt::Break) : Nil
    raise BreakStmt.new("break must be within a for or while loop", stmt.token)
  end

  def visit_next(stmt : Stmt::Next) : Nil
    raise NextStmt.new("next must be within a for or while loop", stmt.token)
  end

  def visit_print(stmt : Stmt::Print) : Nil
    stdout.puts stringify(evaluate(stmt.expression))
  end

  # Expressions

  def visit_literal(expr : Expr::Literal) : LiteralType
    expr.value
  end

  def visit_logical(expr : Expr::Logical) : LiteralType
    left = evaluate(expr.left)

    case expr.operator.type
    when .and?
      left && evaluate(expr.right)
    when .or?
      left || evaluate(expr.right)
    when .nand?
      !left || !evaluate(expr.right)
    when .nor?
      !left && !evaluate(expr.right)
    when .xor?
      !!left == !!evaluate(expr.right)
    when .xnor?
      !!left != !!evaluate(expr.right)
    end
  end

  def visit_grouping(expr : Expr::Grouping) : LiteralType
    evaluate(expr.expression)
  end

  def visit_unary(expr : Expr::Unary) : LiteralType
    right = evaluate(expr.right)

    case expr.operator.type
    when .bang?
      !right
    when .minus?
      case right
      when Float64
        -right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    else
      nil
    end
  end

  def visit_variable(expr : Expr::Variable)
    lookup_variable(expr.name, expr)
  end

  private def lookup_variable(name : Token, expr : Expr) : LiteralType
    distance = locals[expr]?
    if distance.nil?
      globals.get(name)
    else
      env.get_at(name, distance)
    end
  end

  def visit_binary(expr : Expr::Binary) : LiteralType
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when .greater?
      case {left, right}
      when {Float64, Float64}
        left > right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    when .greater_equal?
      case {left, right}
      when {Float64, Float64}
        left >= right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    when .less?
      case {left, right}
      when {Float64, Float64}
        left < right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    when .less_equal?
      case {left, right}
      when {Float64, Float64}
        left <= right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    when .bang_equal?
      left != right
    when .equal_equal?
      left == right
    when .minus?
      case {left, right}
      when {Float64, Float64}
        left - right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    when .plus?
      case {left, right}
      when {Float64, Float64}
        left + right
      when {String, String}
        left + right
      else
        raise error("Operands must be a number or a string.", expr.operator)
      end
    when .slash?
      case {left, right}
      when {Float64, Float64}
        left / right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    when .star?
      case {left, right}
      when {Float64, Float64}
        left * right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    when .modulus?
      case {left, right}
      when {Float64, Float64}
        left % right
      else
        raise error("Operand must be a number.", expr.operator)
      end
    else
      raise error("Unknown operator #{expr.operator.lexeme}.", expr.operator)
    end
  end

  def visit_call(expr : Expr::Call)
    callee = evaluate(expr.callee)

    arguments = [] of LiteralType
    expr.arguments.each do |arg|
      arguments << evaluate(arg)
    end

    unless callee.is_a? LoxCallable
      raise error("Can only call functions and classes", expr.paren)
    end

    function = callee.as(LoxCallable)

    unless arguments.size == function.arity
      raise error("Expected #{function.arity} arguments but got #{arguments.size}.", expr.paren)
    end

    function.call(self, arguments)
  end

  def visit_lambda(expr : Expr::Lambda)
    LoxFunction.new(expr, env, @log)
  end

  def visit_comment(expr : Expr::Comment)
  end

  # Helper methods

  private def stringify(literal : LiteralType) : String
    literal.is_a?(String) ? literal.inspect.to_s : literal.to_s
  end

  private def error(message : String, token : Token) : RuntimeError
    @log.error message, token, "Crylox::Interpreter"
    RuntimeError.new(message, token)
  end
end
