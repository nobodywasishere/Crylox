require "./Token"
require "./TokenTypes"

module Crylox::Scanner
  class Scanner

    @start = 0
    @current = 0
    @line = 1

    def initialize(source : String)
      @source = source
      @tokens = [] of Array(Token)
      @keywords = {
        "and" => TokenType::AND,
        "class" => TokenType::CLASS,
        "else" => TokenType::ELSE,
        "false" => TokenType::FALSE,
        "for" => TokenType::FOR,
        "fun" => TokenType::FUN,
        "if" => TokenType::IF,
        "nil" => TokenType::NIL,
        "or" => TokenType::OR,
        "print" => TokenType::PRINT,
        "return" => TokenType::RETURN,
        "super" => TokenType::SUPER,
        "this" => TokenType::THIS,
        "true" => TokenType::TRUE,
        "var" => TokenType::VAR,
        "while" => TokenType::WHILE
      }
    end

    def scanTokens
      while !at_end?()
        @start = @current
        scanToken()
      end

      @tokens.push([Token.new(TokenType::EOF, "", nil, @line)])
      return @tokens
    end

    private def scanToken()
      c = advance()

      case c
      when '('
        addToken(TokenType::LEFT_PAREN)
      when ')'
        addToken(TokenType::RIGHT_PAREN)
      when '{'
        addToken(TokenType::LEFT_BRACE)
      when '}'
        addToken(TokenType::RIGHT_BRACE)
      when ','
        addToken(TokenType::COMMA)
      when '.'
        addToken(TokenType::DOT)
      when '-'
        addToken(TokenType::MINUS)
      when '+'
        addToken(TokenType::PLUS)
      when ';'
        addToken(TokenType::SEMICOLON)
      when '*'
        addToken(TokenType::STAR)

      when '!'
        addToken(match('=') ? TokenType::BANG_EQUAL : TokenType::BANG)
      when '='
        addToken(match('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL)
      when '<'
        addToken(match('=') ? TokenType::LESS_EQUAL : TokenType::LESS)
      when '>'
        addToken(match('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER)

      when ' ', '\r', '\t'
        nil
      when '/'
        if peek() == '/'
          while peek() != '\n' && !at_end?
            advance()
          end
        else
          addToken(TokenType::SLASH)
        end
      when '\n'
        @line += 1

      when '"'
        string()

      else
        if numeric?(c)
          number()
        elsif alpha?(c)
          identifier()
        else
          Crylox.new().error(@line, "Unexpected character '#{c}'")
        end
      end
    end

    private def identifier
      while alpha?(peek()) || numeric?(peek())
        advance()
      end

      text = @source[@start, @current-1]
      if @keywords.keys.includes? text
        type = @keywords[text]
      else
        type = TokenType::IDENTIFIER
      end
      addToken(type)
    end

    private def number
      while numeric?(peek())
        advance()
      end

      if peek() == '.' && numeric?(peekNext())
        advance()
        while numeric?(peek())
          advance()
        end
      end

      addToken(TokenType::NUMBER, @source[@start..@current-1].to_f)
    end

    private def match(expected : Char)
      return false if at_end?
      return false if @source[@current-1] != expected
      @current += 1
      return true
    end

    private def peek
      return '\0' if at_end?
      return @source[@current]
    end

    private def peekNext()
      return '\0' if @current+1 >= @source.size
      return @source[@current+1]
    end

    private def alpha?(c : Char)

    end

    private def numeric?(c : Char)
      c.ascii_number?
    end

    private def alpha?(c : Char)
      c.ascii_letter? || (c == '_')
    end

    private def at_end?
      @current >= @source.size
    end

    private def advance
      c = @source[@current]
      @current += 1
      return c
    end

    private def addToken(type : TokenType)
      addToken(type, nil)
    end

    private def addToken(type : TokenType, literal)
      text = @source[@start..@current-1]
      @tokens.push([Token.new(type, text, literal, @line)])
    end

    private def string
      while peek() != '"' && !at_end?
        @line += 1 if peek() == '\n'
        advance()
      end

      if at_end?
        Crylox.new().error(@line, "Unterminated string.")
        return
      end

      advance()
      value = @source[@start+1..@current-2]
      addToken(TokenType::STRING, value)
    end
  end
end
