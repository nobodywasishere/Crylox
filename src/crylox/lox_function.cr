class Crylox::LoxFunction
  include LoxCallable

  getter declaration : Stmt::Function
  getter closure : Environment?

  def initialize(@declaration : Stmt::Function, @closure : Environment)
  end

  def arity
    declaration.params.size
  end

  def call(interpreter : Interpreter, arguments : Array(LiteralType)) : LiteralType
    env = Environment.new(closure)

    declaration.params.each_with_index do |param, idx|
      env.define(param, arguments[idx])
    end

    interpreter.execute_block(declaration.body, env)
  rescue return_stmt : Interpreter::ReturnStmt
    return_stmt.value
  end

  def to_s(io : IO)
    io << "<fn #{declaration.name.lexeme}>"
  end
end
