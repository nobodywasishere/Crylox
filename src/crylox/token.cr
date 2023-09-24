class Crylox::Token
  getter type : TokenType
  getter lexeme : String
  getter literal : LiteralType
  getter line : Int32
  getter col : Int32

  def initialize(@type, @lexeme, @literal, @line, @col)
  end

  def to_s(io : IO)
    io << "#{type} #{lexeme.inspect} #{literal.inspect}"
  end
end
