require "../spec_helper"

def parse_source_to_print_ast(source : String) : String?
  scanner = Crylox::Scanner.new(source)
  tokens = scanner.scan_tokens

  parser = Crylox::Parser.new(tokens)
  stmts = parser.parse

  Crylox::Printer.print(stmts)
end

def parse_source_to_print_ast(&) : String?
  parse_source_to_print_ast(yield)
end

describe Crylox::Parser do
  it "parses integers from ast" do
    parse_source_to_print_ast("1 + 1;").should eq("(+ 1.0 1.0)")
  end

  it "parses strings from ast" do
    parse_source_to_print_ast("\"my string\";").should eq("\"my string\"")
  end

  it "removes comments" do
    parse_source_to_print_ast("(1 + 1) == 2;").should eq("(== (group (+ 1.0 1.0)) 2.0)")
  end

  it "parses for loops" do
    parse_source_to_print_ast {
      <<-LOX
      for (var i = 1; i < 5; i = i + 1) {
        print i;
        // hello world
      }
      LOX
    }.should eq(<<-AST)
    (
      (var i 1.0)
      (while ((< (= i) 5.0))
        (
          (
            (print (= i))
            (// hello world)
          )
          (= i (+ (= i) 1.0))
        )
      )
    )
    AST
  end
end
