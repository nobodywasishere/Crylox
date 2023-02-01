#!/usr/bin/env -S crystal run -Dast_printer_main

require "./Expr.cr"

module Crylox::Ast

  class Visitor
  end

  class AstPrinter < Visitor
    def print(expr : Expr::Expr) : String | Nil
      return expr.accept(self)
    end

    def visitBinaryExpr(expr : Expr::Binary) : String
      return parenthesize(expr.operator.lexeme, expr.left, expr.right)
    end

    def visitGroupingExpr(expr : Expr::Grouping) : String
      return parenthesize("group", expr.expression)
    end

    def visitLiteralExpr(expr : Expr::Literal) : String
      return "nil" if expr.value == nil
      return expr.value.to_s
    end

    def visitUnaryExpr(expr : Expr::Unary) : String
      return parenthesize(expr.operator.lexeme, expr.right)
    end

    # Add more `visitTypeExpr(expr : Expr::Type)` here

    private def parenthesize(*exprs) : String
      builder = "(#{exprs.first} "
      exprs[1..].each do |expr|
        builder += " #{expr.accept(self)}"
      end
      builder += ")"
      return builder
    end
  end

  def self.ast_test(args)
    expression : Expr::Expr = Expr::Binary.new(
      Expr::Unary.new(
        Token.new(TokenType::MINUS, "-", nil, 1),
        Expr::Literal.new("123")
      ),
      Token.new(TokenType::STAR, "*", nil, 1),
      Expr::Grouping.new(
        Expr::Literal.new(45.67)
      )
    )

    puts AstPrinter.new().print(expression)
  end
end

{% if flag?(:ast_printer_main) %}
  Crylox::Ast.ast_test(ARGV)
{% end %}
