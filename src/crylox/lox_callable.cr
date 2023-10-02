module Crylox::LoxCallable
  def call(interpreter : Interpreter, arguments : Array(LiteralType)) : LiteralType
    raise "No call method defined for #{self}"
  end

  def arity : Int32
    raise "No arity method defined for #{self}"
  end
end

module Crylox::Native
  class Clock
    include LoxCallable

    def arity
      0
    end

    def call(interpreter, arguments)
      (Time.utc - Time::UNIX_EPOCH).total_seconds
    end

    def to_s(io : IO)
      io << "<native fn>"
    end
  end
end
