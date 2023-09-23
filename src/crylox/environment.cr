class Crylox::Environment
  property enclosing : Environment?

  def initialize(@enclosing = nil)
    @values = {} of String => LiteralType
  end

  def define(name : Token, value : LiteralType)
    @values[name.lexeme] = value
  end

  def get(name : Token)
    if @values.keys.includes? name.lexeme
      return @values[name.lexeme]
    end

    if enclosing.try &.keys.includes? name.lexeme
      return enclosing.try &.get(name)
    end

    raise Crylox::Interpreter::RuntimeError.new("Undefined variable #{name.lexeme}", name)
  end

  def assign(name : Token, value : LiteralType)
    if @values.keys.includes? name.lexeme
      return @values[name.lexeme] = value
    end

    if enclosing.try &.keys.includes? name.lexeme
      return enclosing.try &.assign(name, value)
    end

    raise Crylox::Interpreter::RuntimeError.new("Undefined variable #{name.lexeme}", name)
  end

  def keys
    @values.keys
  end
end
