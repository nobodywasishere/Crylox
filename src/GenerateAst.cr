#!/usr/bin/env -S crystal run -Dgenerate_ast_main

module Crylox::Tools
  def self.defineAst(baseName, types)
    File.open("src/#{baseName}.cr", "w") do |file|
      file.puts "require \"./Token\""
      file.puts
      file.puts "module Crylox::#{baseName}"
      file.puts "  class #{baseName}"
      file.puts "    def accept(visitor : Ast::Visitor)"
      file.puts "      STDERR.puts \"Cannot use '#{baseName}' directly\""
      file.puts "    end"
      file.puts "  end"
      file.puts

      types.each do |type, fields|
        file.puts "  class #{type} < #{baseName}"
        fields.each do |field|
          file.puts "    getter #{field.join(" : ")}"
        end
        file.puts
        file.puts "    def initialize(#{fields.map(&.join(" : ")).join(", ")})"
        fields.each do |field|
          file.puts "      @#{field[0]} = #{field[0]}"
        end
        file.puts "    end"
        file.puts
        file.puts "    def accept(visitor : Ast::Visitor)"
        file.puts "      return visitor.visit#{type}#{baseName}(self)"
        file.puts "    end"
        file.puts "  end"
        file.puts
      end

      file.puts "end"
    end
  end

  def self.main(args)
    defineAst("Expr", {
      "Assign" => [
        ["name", "Token"],
        ["value", "Expr"]
      ],
      "Binary" => [
        ["left", "Expr"],
        ["operator", "Token"],
        ["right", "Expr"]
      ],
      "Grouping" => [
        ["expression", "Expr"]
      ],
      "Unary" => [
        ["operator", "Token"],
        ["right", "Expr"]
      ],
      "Literal" => [
        ["value", "LiteralType"],
      ],
      "Variable" => [
        ["name", "Token"]
      ]
    })

    defineAst("Stmt", {
      "Block" => [
        ["statements", "Array(Stmt)"]
      ],
      "Expression" => [
        ["expression", "Expr::Expr"]
      ],
      "Print" => [
        ["expression", "Expr::Expr"]
      ],
      "Var" => [
        ["name", "Token"],
        ["initializer", "Expr::Expr | Nil"]
      ]
    })
  end
end

{% if flag?(:generate_ast_main) %}
  Crylox::Tools.main(ARGV)
{% end %}
