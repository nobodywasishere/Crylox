module Crylox
  VERSION = "0.1.0"

  alias LiteralType = String | Float64 | Bool | Nil | LoxCallable

  def self.execute(source : String, stdout : IO? = nil, stderr : IO? = nil)
    scanner = Crylox::Scanner.new(source)
    tokens = scanner.scan_tokens

    parser = Crylox::Parser.new(tokens)
    parser.stdout = stdout unless stdout.nil?
    parser.stderr = stderr unless stderr.nil?
    stmts = parser.parse

    interpreter = Crylox::Interpreter.new
    interpreter.stdout = stdout unless stdout.nil?
    interpreter.stderr = stderr unless stderr.nil?
    interpreter.interpret(stmts)
  end

  def self.execute(stdout : IO? = nil, stderr : IO? = nil, &)
    execute(yield, stdout, stderr)
  end
end

require "./crylox/token_type"
require "./crylox/token"
require "./crylox/ast"
require "./crylox/printer"
require "./crylox/scanner"
require "./crylox/parser"
require "./crylox/environment"
require "./crylox/lox_callable"
require "./crylox/lox_function"
require "./crylox/interpreter"
