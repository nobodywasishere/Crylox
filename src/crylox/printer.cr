class Crylox::Printer
  include Crylox::Expr::Visitor
  include Crylox::Stmt::Visitor

  def self.print(stmts : Array(Stmt))
    stmts.map(&.accept(new)).join("\n")
  end

  # Statements

  def visit_block(stmt : Stmt::Block)
    String.build do |str|
      str << "(block\n"
      stmt.statements.each do |s|
        str << "  "
        str << s.accept(self).try &.gsub(/\n/, "\n  ")
        str << "\n"
      end
      str << ")"
    end
  end

  def visit_break(stmt : Stmt::Break)
    "(break)"
  end

  def visit_class(stmt : Stmt::Class)
    String.build do |str|
      str << "(class #{stmt.name.lexeme}"
      stmt.methods.each do |method|
        str << "\n  "
        str << method.accept(self).gsub("\n", "\n  ")
      end
      str << "\n" unless stmt.methods.empty?
      str << ")"
    end
  end

  def visit_expression(stmt : Stmt::Expression)
    stmt.expression.accept(self)
  end

  def visit_function(stmt : Stmt::Function)
    String.build do |str|
      str << "(fun #{stmt.name.lexeme}"
      str << " ("
      str << stmt.params.map(&.lexeme).join(", ")
      str << ")"
      stmt.body.each do |s|
        str << "\n  "
        str << s.accept(self).try &.gsub("\n", "\n  ")
      end
      str << "\n" unless stmt.body.empty?
      str << ")"
    end
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

  def visit_next(stmt : Stmt::Next)
    "(next)"
  end

  def visit_print(stmt : Stmt::Print)
    parenthesize("print", stmt.expression)
  end

  def visit_return(stmt : Stmt::Return)
    parenthesize("return #{stmt.keyword.lexeme}", stmt.value)
  end

  def visit_var(stmt : Stmt::Var)
    if (init = stmt.initializer).nil?
      "(var #{stmt.name.lexeme} nil)"
    else
      parenthesize("var #{stmt.name.lexeme}", init)
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

  # Expressions

  def visit_assign(expr : Expr::Assign)
    parenthesize("= #{expr.name.lexeme}", expr.value)
  end

  def visit_binary(expr : Expr::Binary)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_call(expr : Expr::Call)
    String.build do |str|
      str << "(call "
      str << expr.callee.accept(self)
      str << "("
      str << expr.arguments.map(&.accept(self)).join(", ")
      str << "))"
    end
  end

  def visit_comment(expr : Expr::Comment)
    "(#{expr.body.lexeme})"
  end

  def visit_get(expr : Expr::Get)
    parenthesize("get #{expr.name.lexeme}", expr.object)
  end

  def visit_grouping(expr : Expr::Grouping)
    parenthesize("group", expr.expression)
  end

  def visit_lambda(expr : Expr::Lambda)
    String.build do |str|
      str << "(lambda ("
      str << expr.params.map(&.lexeme).join(", ")
      str << ")"
      expr.body.each do |e|
        str << "\n  "
        str << e.accept(self).try &.gsub(/\n/, "\n  ")
      end
      str << "\n" unless expr.body.empty?
      str << ")"
    end
  end

  def visit_literal(expr : Expr::Literal)
    return "nil" if expr.value.nil?
    expr.value.is_a?(String) ? expr.value.inspect : expr.value.to_s
  end

  def visit_logical(expr : Expr::Logical)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_set(expr : Expr::Set)
    parenthesize("= expr.name", expr.object, expr.value)
  end

  def visit_super(expr : Expr::Super)
    "(super)"
  end

  def visit_this(expr : Expr::This)
    "(this)"
  end

  def visit_unary(expr : Expr::Unary)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  def visit_variable(expr : Expr::Variable)
    "(= #{expr.name.lexeme})"
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
