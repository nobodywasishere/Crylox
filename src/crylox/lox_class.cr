class Crylox::LoxClass
  include LoxCallable

  getter name : String
  getter superclass : LoxClass?
  getter methods : Hash(String, LoxFunction)

  def initialize(@name, @superclass, @methods)
  end

  def call(interpreter, arguments) : LoxInstance
    instance = LoxInstance.new(self)
    initializer = find_method("init")

    unless initializer.nil?
      initializer.bind(instance).call(interpreter, arguments)
    end

    instance
  end

  def arity
    initializer = find_method("init")
    initializer.nil? ? 0 : initializer.arity
  end

  def to_s(io : IO)
    io << name
  end

  def find_method(name : String) : LoxFunction?
    if (method = methods[name]?)
      return method
    end

    if (method = superclass.try &.find_method(name))
      return method
    end

    nil
  end
end
