require "./TokenTypes"

module Crylox
  class Token
    getter type : TokenType
    getter lexeme : String
    getter literal : String | Float64 | Nil
    getter line : Int32

    def initialize(type : TokenType, lexeme : String, literal, line : Int32)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    def to_s
      return "#{@type} #{@lexeme} #{@literal}"
    end
  end
end
