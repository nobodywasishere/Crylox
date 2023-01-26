require "./TokenTypes"

module Crylox
  class Token
    @type : TokenType
    @lexeme : String
    @literal : String | Float64 | Nil
    @line : Int32

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
