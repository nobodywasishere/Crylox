module Crylox
  VERSION = "0.1.0"

  alias LiteralType = String | Float64 | Bool | Nil

  def self.execute(source : String)
    scanner = Crylox::Scanner.new(source)
    tokens = scanner.scan_tokens

    parser = Crylox::Parser.new(tokens)
    stmts = parser.parse

    Crylox::Interpreter.new.interpret(stmts)
  end

  def self.execute(&)
    execute(yield)
  end
end

require "./crylox/token_type"
require "./crylox/token"
require "./crylox/ast"
require "./crylox/printer"
require "./crylox/scanner"
require "./crylox/parser"
require "./crylox/environment"
require "./crylox/interpreter"
