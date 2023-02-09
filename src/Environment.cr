require "./Token"

module Crylox::Env
  class Env
    @enclosing : Env | Nil
    @values : Hash(String, LiteralType) = {} of String => LiteralType

    def initialize
      @enclosing = nil
    end

    def initialize(enclosing : Env)
      @enclosing = enclosing
    end

    def define(name : String, value : LiteralType)
      @values[name] = value
    end

    def get(name : Token)
      if @values.keys.includes? name.lexeme
        return @values[name.lexeme]
      end

      if !@enclosing.nil?
        return @enclosing.try &.get(name)
      end

      raise Interpreter::ExecError.new("Undefined variable '#{name.lexeme}'.", nil, name)
    end

    def assign(name : Token, value : LiteralType) : Nil
      if @values.keys.includes? name.lexeme
        @values[name.lexeme] = value
        return
      end

      if !@enclosing.nil?
        @enclosing.try &.assign(name, value)
        return
      end

      raise Interpreter::ExecError.new("Undefined variable '#{name.lexeme}'.", nil, name)
    end
  end
end
