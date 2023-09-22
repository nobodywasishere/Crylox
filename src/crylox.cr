require "log"

module Crylox
  VERSION = "0.1.0"

  alias LiteralType = String | Float64 | Bool | Nil
end

require "./crylox/token_type"
require "./crylox/token"
require "./crylox/ast"
require "./crylox/printer"
require "./crylox/scanner"
require "./crylox/parser"
require "./crylox/interpreter"
