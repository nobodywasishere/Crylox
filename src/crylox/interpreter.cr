class Crylox::Interpreter < Crylox::Expr::Visitor
  Log = ::Log.for(self)

  class RuntimeError < Exception
    def initialize(message : String, token : Token)
      message = "[line #{token.line}, col #{token.col}]: #{message}"
    end
  end

  def interpret(expression : Expr) : Nil
    puts stringify(evaluate(expression))
  rescue ex : RuntimeError
    puts ex
  end

  def evaluate(expr : Expr) : LiteralType
    expr.accept(self)
  end

  def visit_literal(expr : Expr::Literal) : LiteralType
    Log.debug { "Literal: #{expr.value}" }
    expr.value
  end

  def visit_grouping(expr : Expr::Grouping) : LiteralType
    literal = evaluate(expr.expression)
    Log.debug { "Grouping: #{literal}" }
    literal
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

  def visit_binary(expr : Expr::Binary) : LiteralType
    left = evaluate(expr.left)
    right = evaluate(expr.right)
    Log.debug { "Binary: #{left} #{expr.operator.type} #{right}" }

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
    else
      error("Unknown operator #{expr.operator.lexeme}.", expr.operator)
      nil
    end
  end

  private def stringify(literal : LiteralType) : String
    literal.inspect
  end

  private def error(message : String, token : Token) : RuntimeError
    Log.error &.emit(message, line: token.line, col: token.col)
    RuntimeError.new(message, token)
  end
end
