class Crylox::CrystalTranspiler
  include Crylox::Expr::Visitor
  include Crylox::Stmt::Visitor

  def initialize
    @method_block = false
  end

  def transpile(stmts : Array(Stmt)) : String
    "alias LiteralType = String | Float64 | Bool | Nil\n" +
      stmts.map(&.accept(self)).join("\n")
  end

  # Statements

  # Expressions

  def visit_assign(expr : Expr::Assign) : String
    "#{expr.name.lexeme} = #{expr.value.accept(self)}"
  end

  def visit_binary(expr : Expr::Binary) : String
    "#{expr.left.accept(self)} #{expr.operator.lexeme} #{expr.right.accept(self)}"
  end

  def visit_call(expr : Expr::Call) : String
    "#{expr.callee.accept(self)}.call(#{expr.arguments.map(&.accept(self)).join(", ")})"
  end

  def visit_comment(expr : Expr::Comment) : String
    "# #{expr.body.lexeme.sub(/^\/\/+/, "")}"
  end

  def visit_grouping(expr : Expr::Grouping) : String
    "(#{expr.accept(self)})"
  end

  def visit_lambda(expr : Expr::Lambda) : String
    @method_block = true
    "->(#{expr.params.map { |a| a.lexeme + " : LiteralType" }.join(", ")}) {\n  #{expr.body.map(&.accept(self)).join("\n").gsub("\n", "\n  ")}\n}"
  end

  def visit_literal(expr : Expr::Literal) : String
    expr.value.is_a?(String) ? expr.value.inspect.to_s : expr.value.to_s
  end

  def visit_logical(expr : Expr::Logical) : String
    left = expr.left.accept(self)
    right = expr.right.accept(self)

    case expr.operator.type
    when .and?
      "#{left} && #{right}"
    when .or?
      "#{left} || #{right}"
    when .nand?
      "!(#{left} && #{right})"
    when .nor?
      "!(#{left} || #{right})"
    when .xor?
      "#{left} == #{right}"
    when .xnor?
      "#{left} != #{right}"
    else
      raise "Invalid logical operator #{expr.operator}"
    end
  end

  def visit_variable(expr : Expr::Variable)
    expr.name.lexeme
  end

  def visit_unary(expr : Expr::Unary)
    case expr.operator.type
    when .bang?
      "!#{expr.right}"
    when .minus?
      "-#{expr.right}"
    else
      raise "Invalid unary operator #{expr.operator}"
    end
  end

  # Statements

  def visit_block(stmt : Stmt::Block) : String
    String.build do |str|
      str << "begin\n" if @method_block
      body = stmt.statements.map(&.accept(self)).join("\n")
      body = body.gsub("\n", "\n  ") if @method_block
      str << body
      str << "end" if @method_block
      @method_block = false
    end
  end

  def visit_break(stmt : Stmt::Break) : String
    "break"
  end

  def visit_expression(stmt : Stmt::Expression) : String
    stmt.expression.accept(self)
  end

  def visit_function(stmt : Stmt::Function) : String
    @method_block = true
    "#{stmt.name.lexeme} = ->(#{stmt.params.map { |a| a.lexeme + " : LiteralType" }.join(", ")}) {\n  #{stmt.body.map(&.accept(self)).join("\n").gsub("\n", "\n  ")}\n}"
  end

  def visit_if(stmt : Stmt::If) : String
    String.build do |str|
      str << "if "
      str << stmt.condition.accept(self)
      str << "\n"
      str << stmt.then_branch.accept(self)
      unless stmt.else_branch.nil?
        str << "\nelse"
        str << stmt.else_branch.try &.accept(self)
      end
      str << "\nend"
    end
  end

  def visit_next(stmt : Stmt::Next) : String
    "next"
  end

  def visit_print(stmt : Stmt::Print) : String
    "puts #{stmt.expression.accept(self)}"
  end

  def visit_return(stmt : Stmt::Return) : String
    "return #{stmt.value}"
  end

  def visit_var(stmt : Stmt::Var) : String
    "#{stmt.name.lexeme}#{stmt.initializer.nil? ? "" : " = #{stmt.initializer.try &.accept(self)}"}"
  end

  def visit_while(stmt : Stmt::While) : String
    @method_block = true
    "while #{stmt.condition.accept(self)}\n  #{stmt.body.accept(self).gsub("\n", "\n  ")}\nend"
  end
end
