class Crylox::Environment
  property enclosing : Environment?

  def initialize(@enclosing = nil)
    @values = {} of String => LiteralType
  end

  def define(name : Token, value : LiteralType)
    @values[name.lexeme] = value
  end

  def get(name : Token)
    if defined? name
      return @values[name.lexeme]
    end

    unless enclosing.nil?
      return enclosing.try &.get(name)
    end

    raise Crylox::Interpreter::RuntimeError.new("Undefined variable #{name.lexeme}", name)
  end

  def assign(name : Token, value : LiteralType)
    if defined? name
      return @values[name.lexeme] = value
    end

    unless enclosing.nil?
      return enclosing.try &.assign(name, value)
    end

    raise Crylox::Interpreter::RuntimeError.new("Undefined variable #{name.lexeme}", name)
  end

  def defined?(name : Token)
    @values.keys.any? { |k| k == name.lexeme }
  end
end
