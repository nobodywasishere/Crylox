class Crylox::LoxClass
  include LoxCallable

  getter name : String
  getter methods : Hash(String, LoxFunction)

  def initialize(@name, @methods)
  end

  def call(interpreter, arguments)
    LoxInstance.new(self)
  end

  def arity
    0
  end

  def to_s(io : IO)
    io << name
  end
end
