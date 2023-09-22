require "../spec_helper"

def parse_source(source : String) : String?
  scanner = Crylox::Scanner.new(source)
  tokens = scanner.scan_tokens

  tokens.each { |token| Log.debug { token.inspect } }

  parser = Crylox::Parser.new(tokens)
  expression = parser.parse

  return nil if expression.nil?

  Crylox::Expr::Printer.print(expression)
end

describe Crylox::Parser do
  it "parses integers from ast" do
    parse_source("1 + 1").should eq("(+ 1.0 1.0)")
  end

  it "parses strings from ast" do
    parse_source("\"my string\"").should eq("\"my string\"")
  end

  it "removes comments" do
    parse_source("(1 + 1) == 2 // need to double check").should eq("(== (group (+ 1.0 1.0)) 2.0)")
  end
end
