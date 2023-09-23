class Crylox::Printer
  include Crylox::Expr::Visitor
  include Crylox::Stmt::Visitor

  def self.print(stmts : Array(Stmt))
    stmts.map { |stmt| stmt.accept(new) }.join("\n")
  end

  # Statements

  def visit_block(stmt : Stmt::Block)
    String.build do |str|
      str << "(\n"
      stmt.statements.each do |s|
        str << "  "
        str << s.accept(self).try &.gsub(/\n/, "\n  ")
        str << "\n"
      end
      str << ")"
    end
  end

  def visit_expression(stmt : Stmt::Expression)
    stmt.expression.accept(self)
  end

  def visit_if(stmt : Stmt::If)
    String.build do |str|
      str << "(if ("
      str << stmt.condition.accept(self)
      str << ")\n  "
      str << stmt.then_branch.accept(self).try &.gsub(/\n/, "\n  ")
      unless (else_branch = stmt.else_branch).nil?
        str << "\n  "
        str << else_branch.accept(self).try &.gsub(/\n/, "\n  ")
      end
      str << "\n)"
    end
  end

  def visit_while(stmt : Stmt::While)
    String.build do |str|
      str << "(while ("
      str << stmt.condition.accept(self)
      str << ")\n  "
      str << stmt.body.accept(self).try &.gsub(/\n/, "\n  ")
      str << "\n)"
    end
  end

  def visit_break(stmt : Stmt::Break)
    "(break)"
  end

  def visit_print(stmt : Stmt::Print)
    parenthesize("print", stmt.expression)
  end

  def visit_var(stmt : Stmt::Var)
    if (init = stmt.initializer).nil?
      "(var #{stmt.name.lexeme} nil)"
    else
      parenthesize("var #{stmt.name.lexeme}", init)
    end
  end

  # Expressions

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

  def visit_variable(expr : Expr::Variable)
    "(= #{expr.name.lexeme})"
  end

  def visit_comment(expr : Expr::Comment)
    "(#{expr.body.lexeme})"
  end

  # Helper methods

  private def parenthesize(name : String, *exprs : Expr)
    String.build do |str|
      str << "(#{name}"
      exprs.each { |expr| str << " "; str << expr.accept(self) }
      str << ")"
    end
  end
end
