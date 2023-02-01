require "./AstPrinter"
require "./Expr"
require "./Token"
require "./TokenTypes"

module Crylox::Interpreter
  class ExecError < Exception
    getter token : Token

    def initialize(message : String | Nil = nil, cause : Exception | Nil = nil, token : Token | Nil = nil)
      super(message, cause)
      @token = token
    end
  end

  class Interpreter < Ast::Visitor
    def interpret(expression : Expr::Expr)
      begin
        value : LiteralType = evaluate(expression)
        puts stringify(value)
      rescue e : ExecError
        Crylox.new().exec_error(e)
      end
    end

    def visitBinaryExpr(expr : Expr::Binary) : LiteralType
      left = evaluate(expr.left)
      right = evaluate(expr.right)

      case expr.operator.type
      when TokenType::GREATER
        if left.is_a? Float64 && right.is_a? Float64
          return left > right
        else
          raise ExecError.new("Operands must be two numbers", nil, expr.operator)
        end
      when TokenType::GREATER_EQUAL
        if left.is_a? Float64 && right.is_a? Float64
          return left >= right
        else
          raise ExecError.new("Operands must be two numbers", nil, expr.operator)
        end
      when TokenType::LESS
        if left.is_a? Float64 && right.is_a? Float64
          return left < right
        else
          raise ExecError.new("Operands must be two numbers", nil, expr.operator)
        end
      when TokenType::LESS_EQUAL
        if left.is_a? Float64 && right.is_a? Float64
          return left <= right
        else
          raise ExecError.new("Operands must be two numbers", nil, expr.operator)
        end
        when TokenType::BANG_EQUAL
        return !is_equal?(left, right)
      when TokenType::EQUAL_EQUAL
        return is_equal?(left, right)
      when TokenType::MINUS
        if left.is_a? Float64 && right.is_a? Float64
          return left - right
        else
          raise ExecError.new("Operands must be two numbers", nil, expr.operator)
        end
      when TokenType::SLASH
        if left.is_a? Float64 && right.is_a? Float64
          return left / right
        else
          raise ExecError.new("Operands must be two numbers", nil, expr.operator)
        end
      when TokenType::STAR
        if left.is_a? Float64 && right.is_a? Float64
          return left * right
        else
          raise ExecError.new("Operands must be two numbers", nil, expr.operator)
        end
      when TokenType::PLUS
        if left.is_a? String && right.is_a? String
          return left + right
        elsif left.is_a? Float64 && right.is_a? Float64
          return left + right
        else
          raise ExecError.new("Operands must be two numbers or two strings", nil, expr.operator)
        end
      end

      return nil # Should be unreachable
    end

    def visitGroupingExpr(expr : Expr::Grouping) : LiteralType
      return evaluate(expr.expression)
    end

    def visitLiteralExpr(expr : Expr::Literal) : LiteralType
      return expr.value
    end

    def visitUnaryExpr(expr : Expr::Unary) : LiteralType
      right : LiteralType = evaluate(expr.right)

      case expr.operator.type
      when TokenType::MINUS
        if right.is_a? Float64
          return -1.0 * right if right.is_a? Float64
        else
          raise ExecError.new("Operand must be a number", nil, expr.operator)
        end
      when TokenType::BANG
        return !is_truthy?(right)
      end

      return nil # Should be unreachable
    end

    # private def operand_num?(operator : Token, operand : LiteralType) : Nil
    #   return if operand.is_a? Float64
    #   raise ExecError.new("Operand must be a number", nil, operator)
    # end

    # private def operands_num?(operator : Token, *operands : LiteralType) : Nil
    #   return if operands.all?(&.is_a? Float64)
    #   raise ExecError.new("Operands must be numbers", nil, operator)
    # end

    private def is_truthy?(object : LiteralType) : Bool
      return false if object.nil?
      return object if object.is_a? Bool
      return true
    end

    private def is_equal?(obj_a : LiteralType, obj_b : LiteralType) : Bool
      return true if obj_a.nil? && obj_b.nil?
      return false if obj_a.nil?
      return obj_a == obj_b
    end

    private def stringify(object : LiteralType) : String
      return "nil" if object.nil?
      if object.is_a? Float64
        return object.to_i.to_s if object.to_i.to_f == object
      end
      return object.to_s.inspect if object.is_a? String
      return object.to_s
    end

    private def evaluate(expr : Expr::Expr) : LiteralType
      return expr.accept(self)
    end
  end
end
