#!/usr/bin/env -S crystal run -Dgenerate_ast_main

module Crylox::Tools
  def self.main(args)
    baseName = "Expr"
    types = {
      "Binary" => [
        ["left", "#{baseName}"],
        ["operator", "Token"],
        ["right", "#{baseName}"]
      ],
      "Grouping" => [
        ["expression", "#{baseName}"]
      ],
      "Literal" => [
        ["value", "String | Float64 | Bool | Nil"]
      ],
      "Unary" => [
        ["operator", "Token"],
        ["right", "#{baseName}"]
      ]
    }

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
end

{% if flag?(:generate_ast_main) %}
  Crylox::Tools.main(ARGV)
{% end %}
