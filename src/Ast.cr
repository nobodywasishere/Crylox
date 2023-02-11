require "./Expr.cr"

module Crylox::Ast
  class Visitor; end

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

    def visitVariableExpr(expr : Expr::Variable) : String
      return "`#{expr.name.lexeme}`"
    end

    def visitLogicalExpr(expr : Expr::Logical) : String
      return parenthesize(expr.operator.lexeme, expr.left, expr.right)
    end

    def visitIfStmt(stmt : Stmt::If) : String
      builder = "(if #{stmt.condition.accept(self)}\n"
      @indent += 1
      builder += "#{" "*@indent}#{stmt.thenBranch.accept(self)}\n"
      elseBranch = stmt.elseBranch
      unless elseBranch.nil?
        builder += "#{" "*@indent}#{elseBranch.accept(self)}\n"
      end
      @indent -= 1
      builder += "#{" "*@indent})"
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
end
