class Crylox::Environment
  property enclosing : Environment?

  def initialize(@log : Crylox::Log, @enclosing = nil)
    @values = {} of String => LiteralType
  end

  def define(name : Token, value : LiteralType) : LiteralType
    @values[name.lexeme] = value
  end

  def get(name : Token) : LiteralType
    if defined? name
      return @values[name.lexeme]
    end

    unless enclosing.nil?
      return enclosing.try &.get(name)
    end

    raise error("Undefined variable #{name.lexeme}", name)
  end

  def get_at(name : Token, distance : Int32) : LiteralType
    if distance == 0
      get(name)
    else
      enclosing.try &.get_at(name, distance - 1)
    end
  end

  def assign(name : Token, value : LiteralType) : LiteralType
    if defined? name
      return @values[name.lexeme] = value
    end

    unless enclosing.nil?
      return enclosing.try &.assign(name, value)
    end

    raise error("Undefined variable #{name.lexeme}", name)
  end

  def assign_at(name : Token, value : LiteralType, distance : Int32)
    if distance == 0
      assign(name, value)
    else
      enclosing.try &.assign_at(name, value, distance - 1)
    end
  end

  def defined?(name : Token) : Bool
    @values.keys.any? { |k| k == name.lexeme }
  end

  private def error(message, token) : Interpreter::RuntimeError
    @log.error message, token, "Crylox::Environment"
    Interpreter::RuntimeError.new message, token
  end
end
