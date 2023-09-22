class Crylox::Expr::Printer < Crylox::Expr::Visitor
  def self.print(expr : Expr)
    expr.accept(self.new)
  end

  def visit_assign(expr : Expr::Assign)
    parenthesize("= #{expr.name.lexeme}", expr.value)
  end

  def visit_binary(expr : Expr::Binary)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_grouping(expr : Expr::Grouping)
    parenthesize("group", expr.expression)
  end

  def visit_literal(expr : Expr::Literal)
    return "nil" if expr.value.nil?
    expr.value.is_a?(String) ? expr.value.inspect : expr.value.to_s
  end

  def visit_logical(expr : Expr::Logical)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_unary(expr : Expr::Unary)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  private def parenthesize(name : String, *exprs : Expr)
    String.build do |str|
      str << "(#{name}"
      exprs.each { |expr| str << " "; str << expr.accept(self) }
      str << ")"
    end
  end
end
