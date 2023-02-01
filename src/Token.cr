require "./TokenTypes"

module Crylox
  alias LiteralType = String | Float64 | Bool | Nil

  class Token
    getter type : TokenType
    getter lexeme : String
    getter literal : LiteralType
    getter line : Int32

    def initialize(type : TokenType, lexeme : String, literal : LiteralType, line : Int32)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    def to_s
      return "#{@type} #{@lexeme} #{@literal.inspect}"
    end
  end
end
