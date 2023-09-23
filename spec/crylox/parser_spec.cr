require "../spec_helper"

def parse_source_to_print_ast(source : String) : String?
  scanner = Crylox::Scanner.new(source)
  tokens = scanner.scan_tokens

  tokens.each { |token| Log.debug { token.inspect } }

  parser = Crylox::Parser.new(tokens)
  stmts = parser.parse

  Crylox::Expr::Printer.print(stmts)
end

describe Crylox::Parser do
  it "parses integers from ast" do
    parse_source_to_print_ast("1 + 1").should eq("(+ 1.0 1.0)")
  end

  it "parses strings from ast" do
    parse_source_to_print_ast("\"my string\"").should eq("\"my string\"")
  end

  it "removes comments" do
    parse_source_to_print_ast("(1 + 1) == 2 // need to double check").should eq("(== (group (+ 1.0 1.0)) 2.0)")
  end
end
