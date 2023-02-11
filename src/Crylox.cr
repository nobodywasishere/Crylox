#!/usr/bin/env -S crystal

require "./Scanner"
require "./Parser"
require "./Interpreter"
require "./Ast"

module Crylox
  class Crylox
    @@hadError : Bool = false
    @@hadExecError : Bool = false
    @@interpreter : Interpreter::Interpreter = Interpreter::Interpreter.new

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
      exit(70) if @@hadExecError
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
        @@hadExecError = false
      end
    end

    private def run(source : String)
      scanner = Scanner::Scanner.new(source)
      tokens = scanner.scanTokens
      debug = true

      # if debug
      #   puts "!! Tokens:"
      #   tokens.each do |token|
      #     puts token.to_s
      #   end
      # end

      if debug
        puts "!! Parser:"
      end

      parser = Parser::Parser.new(tokens)
      statements : Array(Stmt::Stmt | Nil) | Nil = parser.parse
      return if @@hadError || statements.nil? || statements.includes? nil

      if debug
        puts "!! Ast:"
        puts Ast::AstPrinter.new.print(statements)

        puts "!! Interpreted:"
      end
      @@interpreter.interpret(statements)
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
        report(token.line, "at end", message)
      else
        report(token.line, "at '#{token.lexeme}'", message)
      end
    end

    def exec_error(e : Interpreter::ExecError)
      @@hadExecError = true
      STDERR.puts "#{e.message}\n[line #{e.token.line}]"
    end
  end
end

Crylox::Crylox.new.main(ARGV)
