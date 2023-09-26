enum Crylox::LoxVariableType
  String
  Number
  LoxCallable
  Bool
  Nil
end

class Crylox::TypeInference
  include Crylox::Expr::Visitor
  include Crylox::Stmt::Visitor

  class TypeError < Crylox::Exception; end

  getter types : Array(Hash(String, LoxVariableType | LoxCallable)) = [{} of String => LoxVariableType | LoxCallable]

  def initialize(@log : Crylox::Log)
  end

  def infer(@log : Crylox::Log, statements : Array(Stmt))
    statements.each(&.accept(self))
  end

  # Expressions

  def visit_assign(expr : Expr::Assign) : Crylox::LoxCallable | Crylox::LoxVariableType
    curr_type = @types.last[expr.name.lexeme]
    new_type = expr.value.accept(self)
    if curr_type != new_type && curr_type != LoxVariableType::Nil
      error("Assignment type mismatch, #{expr.name.lexeme} is a #{curr_type}, got #{new_type}", expr.name)
    else
      @types.last[expr.name.lexeme] = expr.value.accept(self)
    end

    @types.last[expr.name.lexeme]
  end

  def visit_binary(expr : Expr::Binary) : Crylox::LoxCallable | Crylox::LoxVariableType
    left = expr.left.accept(self)
    right = expr.right.accept(self)
    case {left, right}
    when {LoxVariableType::String, LoxVariableType::String}
      LoxVariableType::Bool
    when {LoxVariableType::Number, LoxVariableType::Number}
      LoxVariableType::Bool
    when {LoxVariableType::LoxCallable, LoxVariableType::LoxCallable}
      LoxVariableType::Bool
    when {LoxVariableType::Bool, LoxVariableType::Bool}
      LoxVariableType::Bool
    when {_, LoxVariableType::Nil}
      LoxVariableType::Bool
    when {LoxVariableType::Nil, _}
      LoxVariableType::Bool
    else
      error("Type mismatch, #{left} and #{right} do not support #{expr.operator.lexeme}.", expr.operator)
      LoxVariableType::Nil
    end
  end

  def visit_call(expr : Expr::Call) : Crylox::LoxCallable | Crylox::LoxVariableType
    # if !expr.callee.is_a? LoxVariableType::LoxCallable
    #   raise error("Can only call functions and classes", expr.paren)
    # end

    # callee = expr.callee.accept(self)

    # if !callee.is_a? LoxFunction
    #   return LoxVariableType::Nil
    # end

    # expr.arguments.each(&.accept(self))

    # function = expr.callee.accept(self).as(LoxFunction)

    # if expr.arguments.size != function.arity
    #   raise error("Expected #{function.arity} arguments but got #{expr.arguments.size}.", expr.paren)
    # end

    # arg_idx = 0
    # function.declaration.params.each do |_, param_type|
    #   arg_type = expr.arguments[arg_idx].accept(self)

    #   case {param_type, arg_type}
    #   when {LoxVariableType::String, LoxVariableType::String}
    #   when {LoxVariableType::Number, LoxVariableType::Number}
    #   when {LoxVariableType::LoxCallable, LoxVariableType::LoxCallable}
    #   when {LoxVariableType::Bool, LoxVariableType::Bool}
    #   when {_, LoxVariableType::Nil}
    #   when {LoxVariableType::Nil, _}
    #   else
    #     warning("Argument #{arg_idx} is a #{arg_type}, expecting #{param_type}", expr.paren)
    #   end

    #   arg_idx += 1
    # end

    # function.declaration.body.map(&.accept(self)).last
    LoxVariableType::Nil
  end

  def visit_comment(expr : Expr::Comment) : Crylox::LoxCallable | Crylox::LoxVariableType
    LoxVariableType::Nil
  end

  def visit_grouping(expr : Expr::Grouping) : Crylox::LoxCallable | Crylox::LoxVariableType
    expr.expression.accept(self)
  end

  def visit_lambda(expr : Expr::Lambda) : Crylox::LoxCallable | Crylox::LoxVariableType
    LoxFunction.new(expr, Environment.new(@log), @log)
    # LoxVariableType::Nil
  end

  def visit_literal(expr : Expr::Literal) : Crylox::LoxCallable | Crylox::LoxVariableType
    case expr.value
    when String
      LoxVariableType::String
    when Float64
      LoxVariableType::Number
    when LoxCallable
      LoxVariableType::LoxCallable
    when Bool
      LoxVariableType::Bool
    else
      LoxVariableType::Nil
    end
  end

  def visit_logical(expr : Expr::Logical) : Crylox::LoxCallable | Crylox::LoxVariableType
    left = expr.left.accept(self)
    right = expr.right.accept(self)
    case {left, right}
    when {LoxVariableType::String, LoxVariableType::String}
      left
    when {LoxVariableType::Number, LoxVariableType::Number}
      left
    when {LoxVariableType::Bool, LoxVariableType::Bool}
      left
    when {_, LoxVariableType::Nil}
      left
    when {LoxVariableType::Nil, _}
      right
    else
      error("Type mismatch, #{left} and #{right} do not match.", expr.operator)
      LoxVariableType::Nil
    end
  end

  def visit_variable(expr : Expr::Variable) : Crylox::LoxCallable | Crylox::LoxVariableType
    @types.last[expr.name.lexeme]? || LoxVariableType::Nil
  end

  def visit_unary(expr : Expr::Unary) : Crylox::LoxCallable | Crylox::LoxVariableType
    expr.right.accept(self)
  end

  # Statements

  def visit_block(stmt : Stmt::Block) : Nil
    stmt.statements.map(&.accept(self))
  end

  def visit_break(stmt : Stmt::Break) : Nil
    LoxVariableType::Nil
  end

  def visit_expression(stmt : Stmt::Expression) : Nil
    stmt.expression.accept(self)
  end

  def visit_function(stmt : Stmt::Function) : Nil
    LoxFunction.new(stmt, Environment.new(@log), @log)
  end

  def visit_if(stmt : Stmt::If) : Nil
    condition = stmt.condition.accept(self)
    case condition
    when LoxVariableType::Bool, LoxVariableType::Nil
    else
      warning("if condition always true.", stmt.left_paren)
    end
  end

  def visit_next(stmt : Stmt::Next) : Nil
    LoxVariableType::Nil
  end

  def visit_print(stmt : Stmt::Print) : Nil
    LoxVariableType::Nil
  end

  def visit_return(stmt : Stmt::Return) : Nil
    LoxVariableType::Nil
  end

  def visit_var(stmt : Stmt::Var) : Nil
    @types.last[stmt.name.lexeme] = stmt.lox_type

    unless (init = stmt.initializer).nil?
      infer_type = init.accept(self)

      if stmt.lox_type != LoxVariableType::Nil
        error("Initialization type mismatch, #{stmt.name.lexeme} is a #{stmt.lox_type}, got #{infer_type}", stmt.name)
      else
        @types.last[stmt.name.lexeme] = infer_type
      end
    end
  end

  def visit_while(stmt : Stmt::While) : Nil
    condition = stmt.condition.accept(self)
    case condition
    when LoxVariableType::Bool, LoxVariableType::Nil
    else
      warning("while condition always true.", stmt.left_paren)
    end
  end

  # Helper methods

  private def match_types(left : Expr, right : Expr, token : Token) : LoxVariableType
  end

  private def warning(message : String, token : Token)
    @log.warning message, token, "Crylox::TypeInference"
  end

  private def error(message : String, token : Token) : TypeError
    @log.error message, token, "Crylox::TypeInference"
    TypeError.new(message, token)
  end
end
