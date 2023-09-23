class Crylox::Interpreter
  include Crylox::Expr::Visitor
  include Crylox::Stmt::Visitor

  class RuntimeError < Exception
    def initialize(message : String, token : Token)
      super("  #{" " * (token.col - 1)}^\n[line #{token.line}, col #{token.col}] RuntimeError: #{message}")
    end
  end

  class BreakStmt < RuntimeError
  end

  class NextStmt < RuntimeError
  end

  property env : Crylox::Environment = Crylox::Environment.new

  def interpret(statements : Array(Stmt)) : LiteralType
    last = nil

    statements.each do |stmt|
      last = execute(stmt)
    end

    last
  rescue ex : RuntimeError
    puts ex
  end

  def evaluate(expr : Expr) : LiteralType
    expr.accept(self)
  end

  private def execute(stmt : Stmt)
    stmt.accept(self)
  end

  # Statements

  def visit_block(stmt : Stmt::Block) : LiteralType
    previous_env = env

    env = Environment.new

    stmt.statements.each do |s|
      execute(s)
    end
  ensure
    env = previous_env
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

    env.assign(expr.name, value)

    value
  end

  def visit_expression(stmt : Stmt::Expression) : LiteralType
    evaluate(stmt.expression)
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
      rescue BreakStmt
        break
      end
    end
  end

  def visit_break(stmt : Stmt::Break) : Nil
    raise BreakStmt.new("break must be within a for or while loop", stmt.token)
  end

  def visit_next(stmt : Stmt::Next) : Nil
    raise NextStmt.new("next must be within a for or while loop", stmt.token)
  end

  def visit_print(stmt : Stmt::Print) : Nil
    puts stringify(evaluate(stmt.expression))
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
        error("Operand must be a number.", expr.operator)
      end
    else
      nil
    end
  end

  def visit_variable(expr : Expr::Variable)
    env.get(expr.name)
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
        error("Operand must be a number.", expr.operator)
      end
    when .greater_equal?
      case {left, right}
      when {Float64, Float64}
        left >= right
      else
        error("Operand must be a number.", expr.operator)
      end
    when .less?
      case {left, right}
      when {Float64, Float64}
        left < right
      else
        error("Operand must be a number.", expr.operator)
      end
    when .less_equal?
      case {left, right}
      when {Float64, Float64}
        left <= right
      else
        error("Operand must be a number.", expr.operator)
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
        error("Operand must be a number.", expr.operator)
      end
    when .plus?
      case {left, right}
      when {Float64, Float64}
        left + right
      when {String, String}
        left + right
      else
        error("Operands must be a number or a string.", expr.operator)
      end
    when .slash?
      case {left, right}
      when {Float64, Float64}
        left / right
      else
        error("Operand must be a number.", expr.operator)
      end
    when .star?
      case {left, right}
      when {Float64, Float64}
        left * right
      else
        error("Operand must be a number.", expr.operator)
      end
    when .modulus?
      case {left, right}
      when {Float64, Float64}
        left % right
      else
        error("Operand must be a number.", expr.operator)
      end
    else
      error("Unknown operator #{expr.operator.lexeme}.", expr.operator)
      nil
    end
  end

  def visit_comment(expr : Expr::Comment)
  end

  # Helper methods

  private def stringify(literal : LiteralType) : String
    literal.inspect
  end

  private def error(message : String, token : Token) : RuntimeError
    raise RuntimeError.new(message, token)
  end
end
