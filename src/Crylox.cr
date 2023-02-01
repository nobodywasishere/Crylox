#!/usr/bin/env -S crystal run -Dcrylox_main

require "./Scanner"
require "./Parser"
require "./AstPrinter"

module Crylox
  class Crylox
    @@hadError : Bool = false

    def main(args : Array(String))
      if args.size > 1
        STDOUT.puts "Usage: crylox [script]"
      elsif args.size == 1
        runFile(args[0])
      else
        runPrompt()
      end
    end

    private def runFile(path : String)
      bytes = File.read(path)
      run(bytes)
      exit(65) if @@hadError
    end

    private def runPrompt
      while true
        print "> "
        line = gets("\n")
        unless line.nil?
          run(line)
        else
          break
        end
        @@hadError = false
      end
    end

    private def run(source : String)
      scanner = Scanner::Scanner.new(source)
      tokens = scanner.scanTokens()

      puts "Tokens:"
      tokens.each do |token|
        puts token.to_s
      end

      parser = Parser::Parser.new(tokens)
      expression : Expr::Expr | Nil = parser.parse()
      return if @@hadError || expression.nil?
      puts "Ast:"
      puts Ast::AstPrinter.new().print(expression)
    end

    def error(line : Int32, message : String)
      @hadError = true
      report line, "", message
    end

    private def report(line : Int32, where : String, message : String)
      STDERR.puts "[line #{line}] Error #{where}: #{message}"
    end

    def error(token : Token, message : String)
      @@hadError = true
      if token.type == TokenType::EOF
        report(token.line, " at end", message)
      else
        report(token.line, " at '#{token.lexeme}'", message)
      end
    end
  end
end

{% if flag?(:crylox_main) %}
  Crylox::Crylox.new.main(ARGV)
{% end %}
