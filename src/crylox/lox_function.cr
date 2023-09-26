class Crylox::LoxFunction
  include LoxCallable

  getter declaration : Stmt::Function | Expr::Lambda
  getter closure : Environment?

  def initialize(@declaration, @closure, @log : Crylox::Log)
  end

  def arity : Int32
    declaration.params.size
  end

  def call(interpreter : Interpreter, arguments : Array(LiteralType)) : LiteralType
    env = Environment.new(@log, closure)

    declaration.params.keys.each_with_index do |param, idx|
      env.define(param, arguments[idx])
    end

    interpreter.execute_block(declaration.body, env)
  rescue return_stmt : Interpreter::ReturnStmt
    return_stmt.value
  end

  def to_s(io : IO)
    if declaration.is_a? Stmt::Function
      io << "<fn #{declaration.as(Stmt::Function).name.lexeme}>"
    else
      io << "<fn lambda>"
    end
  end
end
