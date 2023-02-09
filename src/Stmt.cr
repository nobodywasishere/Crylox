require "./Token"

module Crylox::Stmt
  class Stmt
    def accept(visitor : Ast::Visitor)
      STDERR.puts "Cannot use 'Stmt' directly"
    end
  end

  class Block < Stmt
    getter statements : Array(Stmt)

    def initialize(statements : Array(Stmt))
      @statements = statements
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitBlockStmt(self)
    end
  end

  class Expression < Stmt
    getter expression : Expr::Expr

    def initialize(expression : Expr::Expr)
      @expression = expression
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitExpressionStmt(self)
    end
  end

  class Print < Stmt
    getter expression : Expr::Expr

    def initialize(expression : Expr::Expr)
      @expression = expression
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitPrintStmt(self)
    end
  end

  class Var < Stmt
    getter name : Token
    getter initializer : Expr::Expr | Nil

    def initialize(name : Token, initializer : Expr::Expr | Nil)
      @name = name
      @initializer = initializer
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitVarStmt(self)
    end
  end
end
