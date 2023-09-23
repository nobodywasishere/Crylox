class Crylox::Scanner
  Keywords = {
    "and"    => :and,
    "or"     => :or,
    "nand"   => :nand,
    "nor"    => :nor,
    "xor"    => :xor,
    "xnor"   => :xnor,
    "class"  => :class,
    "else"   => :else,
    "false"  => :false,
    "for"    => :for,
    "fun"    => :fun,
    "if"     => :if,
    "nil"    => :nil,
    "print"  => :print,
    "return" => :return,
    "super"  => :super,
    "this"   => :this,
    "true"   => :true,
    "var"    => :var,
    "while"  => :while,
    "break"  => :break,
    "next"   => :next,
  } of String => TokenType

  def initialize(source : String)
    @source = source
    @tokens = [] of Token
    @start = 0
    @current = 0
    @line = 1
    @col = 0
  end

  def scan_tokens : Array(Token)
    until at_end?
      @start = @current
      scan_token
    end

    @tokens << Token.new(:eof, "", nil, @line, @col)
    @tokens
  end

  private def scan_token
    char = advance

    case char
    when '('
      add_token(:left_paren)
    when ')'
      add_token(:right_paren)
    when '{'
      add_token(:left_brace)
    when '}'
      add_token(:right_brace)
    when ','
      add_token(:comma)
    when '.'
      add_token(:dot)
    when '-'
      add_token(:minus)
    when '+'
      add_token(:plus)
    when ';'
      add_token(:semicolon)
    when '*'
      add_token(:star)
    when '%'
      add_token(:modulus)
    when '!'
      match('=') ? add_token(:bang_equal) : add_token(:bang)
    when '='
      match('=') ? add_token(:equal_equal) : add_token(:equal)
    when '<'
      match('=') ? add_token(:less_equal) : add_token(:less)
    when '>'
      match('=') ? add_token(:greater_equal) : add_token(:greater)
    when ' ', '\r', '\t'
    when '\n'
      @line += 1
      @col = 0
    when '/'
      if match('/')
        until peek == '\n' || at_end?
          advance
        end
        add_token(:comment, @source[@start...@current].sub(/^\/\/+ */, ""))
      else
        add_token(:slash)
      end
    when '"'
      string
    else
      if char.ascii_number?
        number
      elsif char.ascii_letter? || char == '_'
        identifier
      else
        error("Unexpected character #{char.inspect}.")
      end
    end
  end

  private def string
    until peek == '"' || at_end?
      if peek == '\n'
        @line += 1
        @col = 0
      end

      advance
    end

    if at_end?
      error("Unterminated string.")
      return
    end

    advance

    add_token(:string, @source[@start + 1...@current - 1])
  end

  private def number
    while peek.ascii_number?
      advance
    end

    if peek == '.' && peek_next.ascii_number?
      advance

      while peek.ascii_number?
        advance
      end
    end

    add_token(:number, @source[@start...@current].to_f)
  end

  private def identifier
    while peek.alphanumeric? || peek == '_'
      advance
    end

    text = @source[@start...@current]
    type = Keywords.fetch(text, TokenType::IDENTIFIER)

    add_token(type)
  end

  private def match(expected : Char)
    return false if at_end? || @source[@current] != expected
    @current += 1
    return true
  end

  private def peek : Char
    return '\0' if at_end?
    return @source[@current]
  end

  private def peek_next : Char
    return '\0' if @current > @source.size
    @source[@current + 1]
  end

  private def at_end? : Bool
    @current >= @source.size
  end

  private def advance : Char
    c = @source[@current]

    @current += 1
    @col += 1

    c
  end

  private def add_token(type : TokenType, literal : LiteralType = nil)
    text = @source[@start...@current]
    @tokens << Token.new(type, text, literal, @line, @col)
  end

  private def error(message : String)
  end
end
