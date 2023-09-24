class Crylox::Log
  enum Level
    Debug
    Info
    Warning
    Error
  end

  getter stdout : IO
  getter stderr : IO

  getter source : String?
  getter level : Level

  getter? had_error : Bool = false

  def initialize(@source : String?, level : Level? = nil, @stdout = STDOUT, @stderr = STDERR)
    @level = level || Level.parse(ENV["LOG_LEVEL"]? || "Info")
  end

  def debug(message : String, token : Token, for_obj : String = "")
    log(stderr, message, token, :debug, for_obj)
  end

  def info(message : String, token : Token, for_obj : String = "")
    log(stdout, message, token, :info, for_obj)
  end

  def warning(message : String, token : Token, for_obj : String = "")
    log(stderr, message, token, :warning, for_obj)
  end

  def error(message : String, token : Token, for_obj : String = "")
    @had_error = true
    log(stderr, message, token, :error, for_obj)
  end

  private def log(io : IO, message : String, token : Token, level : Level, for_obj = "")
    str = String.build do |str|
      unless @source.nil?
        @source = @source.as(String)

        source_line = source.try(&.split("\n")[token.line - 1])

        str << "  "
        str << source_line
        str << "\n "
        str << " " * token.col
        str << "^\n"
      end

      str << "[line #{token.line}, col #{token.col}] "
      str << for_obj
      str << " #{level}: #{message}"
    end

    io.puts str
  end
end
