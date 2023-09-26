module Crylox::LoxCallable
  abstract def call(interpreter : Interpreter, arguments : Array(LiteralType)) : LiteralType

  abstract def arity : Int32

  abstract def to_s(io : IO)
end

module Crylox::Native
  class Clock
    include LoxCallable

    def arity : Int32
      0
    end

    def call(interpreter, arguments) : Float64
      (Time.utc - Time::UNIX_EPOCH).total_seconds
    end

    def to_s(io : IO)
      io << "<native fn clock>"
    end
  end

  class TypeOf
    include LoxCallable

    def arity : Int32
      1
    end

    def call(interpreter, arguments) : String
      case arguments.first
      when String
        LoxVariableType::String.to_s
      when Float64
        LoxVariableType::Number.to_s
      when LoxCallable
        LoxVariableType::LoxCallable.to_s
      when Bool
        LoxVariableType::Bool.to_s
      else
        LoxVariableType::Nil.to_s
      end
    end

    def to_s(io : IO)
      io << "<native fn typeof>"
    end
  end
end
