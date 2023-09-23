require "../crylox"

class Crylox::CLI
  def execute(args : Array(String))
    case args[0]?
    when "i", "interpreter", nil
      run_prompt
    when "f", "file"
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
    loop do
      print ">> "
      line = gets

      break if line.nil?
      next if line.empty?

      begin
        if ast
          run_ast line
        else
          res = run(line)
          puts "=: #{res.is_a?(String) ? res.inspect : res}"
        end
      rescue ex : Parser::ParseError | Interpreter::RuntimeError
      end
    end
  end

  private def run(source : String) : LiteralType
    @interpreter ||= Interpreter.new

    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens)
    statements = parser.parse

    @interpreter.try &.interpret(statements)
  end

  private def run_ast(source : String)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens)
    statements = parser.parse

    puts Crylox::Printer.print(statements)
  end
end

Crylox::CLI.new.execute(ARGV)
