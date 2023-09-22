require "../crylox"

class Crylox::CLI
  Log = ::Log.for(self)

  def execute(args : Array(String))
    case args.size
    when 0
      run_prompt
    when 1
      run_file(args.first)
    else
      puts "Usage: crylox [script]"
      exit 64
    end
  end

  private def run_file(path : String)
    run File.read(path)
  end

  private def run_prompt
    while true
      print "> "
      line = gets

      break if line.nil?
      next if line.empty?

      run line
    end
  end

  private def run(source : String)
    @interpreter ||= Interpreter.new

    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    tokens.each { |token| Log.debug { token.inspect } }

    parser = Parser.new(tokens)
    expression = parser.parse

    return if expression.nil?

    @interpreter.try &.interpret(expression)
  end
end

Crylox::CLI.new.execute(ARGV)
