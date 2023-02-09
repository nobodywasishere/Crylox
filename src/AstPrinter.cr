#!/usr/bin/env -S crystal run -Dast_printer_main

require "./Expr.cr"

module Crylox::Ast

  class Visitor
  end

  class AstPrinter < Visitor
    @indent : Int32 = 1

    def print(statements : Array(Stmt::Stmt | Nil)) : String | Nil
      builder = "(\n"
      statements.each do |statement|
        part = statement.accept(self) if !statement.nil?
        unless part.nil?
          builder += " " + part + "\n"
        end
      end
      builder += ")"
      return builder
    end

    def visitBinaryExpr(expr : Expr::Binary) : String
      return parenthesize(expr.operator.lexeme, expr.left, expr.right)
    end

    def visitGroupingExpr(expr : Expr::Grouping) : String
      return parenthesize("group", expr.expression)
    end

    def visitLiteralExpr(expr : Expr::Literal) : String
      return "nil" if expr.value == nil
      if expr.value.is_a? String
        return expr.value.to_s.inspect
      else
        return expr.value.to_s
      end
    end

    def visitUnaryExpr(expr : Expr::Unary) : String
      return parenthesize(expr.operator.lexeme, expr.right)
    end

    def visitVariableExpr(expr : Expr::Variable) : LiteralType
      return "`#{expr.name.lexeme}`"
    end

    def visitBlockStmt(stmt : Stmt::Block) : String
      builder = "(\n"
      @indent += 1
      stmt.statements.each do |statement|
        retn = statement.accept(self)
        unless retn.nil?
          builder += "#{" "*@indent}" + retn + "\n"
        end
      end
      @indent -= 1
      builder += "#{" "*@indent})"
    end

    def visitExpressionStmt(stmt : Stmt::Expression) : String
      return stmt.expression.accept(self) || ""
    end

    def visitPrintStmt(stmt : Stmt::Print) : String
      return parenthesize("print", stmt.expression)
    end

    def visitVarStmt(stmt : Stmt::Var) : String
      if stmt.initializer.nil?
        return "(var #{stmt.name.to_s} := nil)"
      else
        return parenthesize("var `#{stmt.name.lexeme}` :=", stmt.initializer)
      end
    end

    def visitAssignExpr(expr : Expr::Assign) : String
      return parenthesize("`#{expr.name.lexeme}` :=", expr.value)
    end

    private def parenthesize(*exprs) : String
      builder = "(#{exprs.first}"
      exprs[1..].each do |expr|
        builder += " #{expr.accept(self)}" if !expr.nil?
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
