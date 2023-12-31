class Crylox::LoxFunction
  include LoxCallable

  getter declaration : Stmt::Function | Expr::Lambda
  getter closure : Environment?
  getter? initializer : Bool

  def initialize(@declaration, @closure, @initializer, @log : Crylox::Log)
  end

  def arity
    declaration.params.size
  end

  def call(interpreter : Interpreter, arguments : Array(LiteralType)) : LiteralType
    env = Environment.new(@log, closure)

    declaration.params.each_with_index do |param, idx|
      env.define(param, arguments[idx])
    end

    value = interpreter.execute_block(declaration.body, env)
  rescue return_stmt : Interpreter::ReturnStmt
    if initializer?
      closure.try &.get_at(Token.new(:this, "this", "this", 0, 0), 0)
    else
      return_stmt.value
    end
  end

  def to_s(io : IO)
    if declaration.is_a? Stmt::Function
      io << "<fn #{declaration.as(Stmt::Function).name.lexeme}>"
    else
      io << "<fn lambda>"
    end
  end

  def bind(instance : LoxInstance)
    env = Environment.new(@log, closure)
    env.define(Token.new(:this, "this", "this", 0, 0), instance)
    LoxFunction.new(declaration, env, initializer?, @log)
  end
end
