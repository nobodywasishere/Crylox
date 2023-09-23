require "../crylox"

class Crylox::CLI
  Log = ::Log.for(self)

  def execute(args : Array(String))
    case args.first
    when "i", nil
      run_prompt
    when "f"
      run_file(args[1])
    when "ast"
      run_prompt(true)
    else
      puts "Usage: crylox [cmd] [script]"
      exit 64
    end
  end

  private def run_file(path : String)
    run File.read(path)
  end

  private def run_prompt(ast = false)
    while true
      print "> "
      line = gets

      break if line.nil?
      next if line.empty?

      if ast
        run_ast line
      else
        run line
      end
    end
  end

  private def run(source : String)
    @interpreter ||= Interpreter.new

    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    tokens.each { |token| Log.debug { token.inspect } }

    parser = Parser.new(tokens)
    statements = parser.parse

    @interpreter.try &.interpret(statements)
  end

  private def run_ast(source : String)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens)
    statements = parser.parse

    puts Crylox::Expr::Printer.print(statements)
  end
end

Crylox::CLI.new.execute(ARGV)
