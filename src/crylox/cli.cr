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
    when "to_crystal"
      transpile_crystal(File.read(args[1]))
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
          res, err = run(line)
          puts "=: #{res.is_a?(String) ? res.inspect : res}" unless err
        end
      rescue ex : Crylox::Exception
      end
    end
  end

  private def run(source : String, log : Crylox::Log? = nil) : {LiteralType, Bool}
    log ||= Crylox::Log.new(source)

    @interpreter ||= Interpreter.new(log)

    scanner = Scanner.new(source, log)
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens, log)
    statements = parser.parse

    resolver = Resolver.new(@interpreter.as(Interpreter), log)
    resolver.resolve(statements)

    {@interpreter.as(Interpreter).interpret(log, statements), log.had_error?}
  end

  private def run_ast(source : String)
    log = Log.new(source)

    scanner = Scanner.new(source, log)
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens, log)
    statements = parser.parse

    puts Crylox::Printer.print(statements)
  end

  private def transpile_crystal(source : String)
    log = Log.new(source)

    scanner = Scanner.new(source, log)
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens, log)
    statements = parser.parse

    transpiler = CrystalTranspiler.new

    puts transpiler.transpile(statements)
  end
end

Crylox::CLI.new.execute(ARGV)
