macro define_ast(name, types)
  abstract class {{name}}
    def accept(visitor : Visitor)
    end
  end

  module {{name}}::Visitor
    {% for type, fields in types %}
    def visit_{{type.downcase.id}}({{name.id.downcase}} : {{name}}::{{type.id}})
      raise "Undefined visitor method visit_{{type.downcase.id}}."
    end
    {% end %}
  end

  {% for type, fields in types %}
  class {{name}}::{{type.id}} < {{name}}

    {% for field in fields %}
    getter {{field.id}}
    {% end %}

    def initialize(
      {% for field in fields %}
      @{{field.id}},
      {% end %}
      )
    end

    def accept(visitor : Visitor)
      visitor.visit_{{type.downcase.id}}(self)
    end
  end
  {% end %}
end

module Crylox
  define_ast Expr, {
    "Assign" => [
      "name : Token",
      "value : Expr",
    ],
    "Binary" => [
      "left : Expr",
      "operator : Token",
      "right : Expr",
    ],
    "Grouping" => [
      "expression : Expr",
    ],
    "Unary" => [
      "operator : Token",
      "right : Expr",
    ],
    "Literal" => [
      "value : LiteralType",
    ],
    "Variable" => [
      "name : Token",
    ],
    "Logical" => [
      "left : Expr",
      "operator : Token",
      "right : Expr",
    ],
  }

  define_ast Stmt, {
    "Block" => [
      "statements : Array(Stmt)",
    ],
    "Expression" => [
      "expression : Expr",
    ],
    "If" => [
      "condition : Expr",
      "then_branch : Stmt",
      "else_branch : Stmt?",
    ],
    "Print" => [
      "expression : Expr",
    ],
    "Var" => [
      "name : Token",
      "initializer : Expr?",
    ],
  }
end
