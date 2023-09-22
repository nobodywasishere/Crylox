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

      if line.nil?
        break
      end

      run line
    end
  end

  private def run(source : String)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    tokens.each { |token| Log.debug { token.inspect } }

    parser = Parser.new(tokens)
    expression = parser.parse

    if expression.nil?
      return
    end

    puts Crylox::Expr::Printer.print(expression)
  end
end

Crylox::CLI.new.execute(ARGV)
