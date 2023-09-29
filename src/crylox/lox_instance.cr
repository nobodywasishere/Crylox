class Crylox::LoxInstance
  private getter klass : LoxClass
  private getter fields : Hash(String, LiteralType) = {} of String => LiteralType

  def initialize(@klass : LoxClass)
  end

  def to_s(io : IO)
    io << klass.name + " instance"
  end

  def get(name : Token) : LiteralType
    if (value = fields[name.lexeme]?)
      return value
    end

    if (method = klass.methods[name.lexeme]?)
      return method
    end

    raise Interpreter::RuntimeError.new("Undefined property '#{name.lexeme}'.", name)
  end

  def set(name : Token, value : LiteralType) : LiteralType
    fields[name.lexeme] = value
    value
  end
end
