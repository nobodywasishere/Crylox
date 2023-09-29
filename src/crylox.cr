module Crylox
  VERSION = "0.1.0"

  alias LiteralType = String | Float64 | Bool | Nil | LoxCallable | LoxInstance

  record ExecResult, result : LiteralType, stdout : String, stderr : String

  def self.execute(source : String) : ExecResult
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    log = Crylox::Log.new(source, stdout: stdout, stderr: stderr)

    scanner = Scanner.new(source, log)
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens, log)
    stmts = parser.parse

    interpreter = Interpreter.new(log)
    interpreter.stdout = stdout

    resolver = Resolver.new(interpreter, log)
    resolver.resolve(stmts)

    res = interpreter.interpret(log, stmts)

    ExecResult.new res, stdout.to_s, stderr.to_s
  end

  def self.execute(&) : ExecResult
    execute(yield)
  end
end

require "./crylox/log"
require "./crylox/exception"
require "./crylox/token_type"
require "./crylox/token"
require "./crylox/ast"
require "./crylox/printer"
require "./crylox/scanner"
require "./crylox/parser"
require "./crylox/resolver"
require "./crylox/environment"
require "./crylox/lox_callable"
require "./crylox/lox_class"
require "./crylox/lox_function"
require "./crylox/lox_instance"
require "./crylox/interpreter"
