require "./Token"

module Crylox::Expr
  class Expr
    def accept(visitor : Ast::Visitor)
      STDERR.puts "Cannot use 'Expr' directly"
    end
  end

  class Assign < Expr
    getter name : Token
    getter value : Expr

    def initialize(name : Token, value : Expr)
      @name = name
      @value = value
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitAssignExpr(self)
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

  class Literal < Expr
    getter value : LiteralType

    def initialize(value : LiteralType)
      @value = value
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitLiteralExpr(self)
    end
  end

  class Variable < Expr
    getter name : Token

    def initialize(name : Token)
      @name = name
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitVariableExpr(self)
    end
  end

  class Logical < Expr
    getter left : Expr
    getter operator : Token
    getter right : Expr

    def initialize(left : Expr, operator : Token, right : Expr)
      @left = left
      @operator = operator
      @right = right
    end

    def accept(visitor : Ast::Visitor)
      return visitor.visitLogicalExpr(self)
    end
  end

end
