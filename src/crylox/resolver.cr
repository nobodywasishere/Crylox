class Crylox::Resolver
  include Crylox::Expr::Visitor
  include Crylox::Stmt::Visitor

  class ResolveError < Crylox::Exception; end

  enum FunctionType
    None
    Function
  end

  getter interpreter : Interpreter
  getter scopes : Array(Hash(String, Bool)) = [{} of String => Bool]
  property current_function : FunctionType = :none

  def initialize(@interpreter, @log : Crylox::Log)
  end

  def resolve(statements : Array(Stmt)) : Nil
    statements.each do |stmt|
      resolve stmt
    end
  end

  # Stmts

  def visit_block(stmt : Stmt::Block) : Nil
    begin_scope
    resolve stmt.statements
    end_scope
  end

  def visit_break(stmt) : Nil
  end

  def visit_expression(stmt : Stmt::Expression) : Nil
    resolve stmt.expression
  end

  def visit_function(stmt : Stmt::Function) : Nil
    declare stmt.name
    define stmt.name
    resolve_function stmt, :function
  end

  def visit_if(stmt : Stmt::If) : Nil
    resolve stmt.condition
    resolve stmt.then_branch
    resolve stmt.else_branch.as(Stmt) unless stmt.else_branch.nil?
  end

  def visit_next(stmt) : Nil
  end

  def visit_print(stmt : Stmt::Print) : Nil
    resolve stmt.expression
  end

  def visit_return(stmt : Stmt::Return) : Nil
    if current_function == :none
      raise error("Cannot return from top-level code.", stmt.keyword)
    end

    resolve stmt.value
  end

  def visit_var(stmt : Stmt::Var) : Nil
    declare stmt.name
    unless stmt.initializer.nil?
      resolve stmt.initializer.as(Expr)
    end
    define stmt.name
  end

  def visit_while(stmt : Stmt::While) : Nil
    resolve stmt.condition
    resolve stmt.body
  end

  # Exprs

  def visit_assign(expr : Expr::Assign) : Nil
    resolve expr.value
    resolve_local expr, expr.name
  end

  def visit_binary(expr : Expr::Binary) : Nil
    resolve expr.left
    resolve expr.right
  end

  def visit_call(expr : Expr::Call) : Nil
    resolve expr.callee

    expr.arguments.each do |arg|
      resolve arg
    end
  end

  def visit_comment(expr : Expr::Comment) : Nil
  end

  def visit_grouping(expr : Expr::Grouping) : Nil
    resolve expr.expression
  end

  def visit_lambda(expr : Expr::Lambda) : Nil
    resolve_function expr, :function
  end

  def visit_literal(expr : Expr::Literal) : Nil
  end

  def visit_logical(expr : Expr::Logical) : Nil
    resolve expr.left
    resolve expr.right
  end

  def visit_unary(expr : Expr::Unary) : Nil
    resolve expr.right
  end

  def visit_variable(expr : Expr::Variable) : Nil
    if !scopes.empty? && scopes.last[expr.name.lexeme]? == false
      raise error("Can't read local variable #{expr.name.lexeme} in its own initializer.", expr.name)
    end

    resolve_local expr, expr.name
  end

  # Helper methods

  private def begin_scope
    @scopes << {} of String => Bool
  end

  private def end_scope
    @scopes.pop
  end

  private def declare(name : Token) : Nil
    return if scopes.empty?

    if scopes.last.has_key? name.lexeme
      raise error("There is already a variable named #{name.lexeme} in this scope.", name)
    end

    scopes.last[name.lexeme] = false
  end

  private def define(name : Token) : Nil
    return if scopes.empty?

    scopes.last[name.lexeme] = true
  end

  private def resolve(stmt : Stmt) : Nil
    stmt.accept(self)
  end

  private def resolve(expr : Expr) : Nil
    expr.accept(self)
  end

  private def resolve_local(expr : Expr, name : Token)
    (0...scopes.size).reverse_each do |idx|
      if scopes[idx].has_key?(name.lexeme)
        interpreter.resolve expr, scopes.size - 1 - idx
        return
      end
    end
  end

  private def resolve_function(function : Stmt::Function | Expr::Lambda, type : FunctionType)
    enclosing_function = current_function
    current_function = type

    begin_scope
    function.params.each do |param|
      declare param
      define param
    end
    resolve function.body
    end_scope

    current_function = enclosing_function
  end

  private def error(message : String, token : Token)
    @log.error message, token, "Crylox::Resolver"
    ResolveError.new(message, token)
  end
end
