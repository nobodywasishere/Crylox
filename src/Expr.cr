require "./Token"

module Crylox::Expr
  class Expr
    def accept(visitor : Ast::Visitor)
      STDERR.puts "Cannot use 'Expr' directly"
    end
  end

  class Binary < Expr
    getter left : Expr
    getter operator : Token
    getter right : Expr

    def initialize(left : Expr, operator : Token, right : Expr)
      @left = left
      @operator = operator
      @right = right
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitBinaryExpr(self)
    end
  end

  class Grouping < Expr
    getter expression : Expr

    def initialize(expression : Expr)
      @expression = expression
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitGroupingExpr(self)
    end
  end

  class Literal < Expr
    getter value : String | Float64 | Bool | Nil

    def initialize(value : String | Float64 | Bool | Nil)
      @value = value
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitLiteralExpr(self)
    end
  end

  class Unary < Expr
    getter operator : Token
    getter right : Expr

    def initialize(operator : Token, right : Expr)
      @operator = operator
      @right = right
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitUnaryExpr(self)
    end
  end

end
