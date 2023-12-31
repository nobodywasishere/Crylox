module Crylox
  # Macro for defining a module to hold AST types, utilizing the visitor architecture.
  # If passed a block with `ast_type` calls, it will automatically insert the name as
  # the first argument.
  #
  # ```
  # ast_module Expr do
  #   ast_type Lambda, params : Array(Token), body : Array(Stmt)
  #   # => ast_type Expr, Lambda, params : Array(Token), body : Array(Stmt)
  # end
  # ```
  macro ast_module(name, &block)
    abstract class {{name.id}}
      abstract def accept(visitor : {{name.id}}::Visitor)
    end

    {% if block.is_a?(Block) %}
    {% for node in block.body.expressions %}
    {% if node.is_a?(Call) && node.name == "ast_type" %}
    {{ node.name }}({{ name.id }}, {{ node.args.splat }})
    {% end %}
    {% end %}
    {% end %}

    module {{name.id}}::Visitor
    end
  end

  # Macro for defining an AST type, utilizing the visitor architecture. If called within a block passed to
  # `ast_module`, the first argument is not necessary
  macro ast_type(ast_class, name, *properties)
    class {{ast_class.id}}::{{name.id}} < {{ast_class.id}}
      {% for property in properties %}
        {% if property.is_a?(Assign) %}
          getter {{property.target.id}}
        {% elsif property.is_a?(TypeDeclaration) %}
          getter {{property}}
        {% else %}
          getter :{{property.id}}
        {% end %}
      {% end %}

      def initialize({{
                       *properties.map do |field|
                         "@#{field.id}".id
                       end
                     }})
      end

      def accept(visitor : {{ast_class.id}}::Visitor)
        visitor.visit_{{name.id.downcase}}(self)
      end
    end

    module {{ast_class.id}}::Visitor
      abstract def visit_{{name.id.downcase}}({{ast_class.id.downcase}} : {{ast_class.id}}::{{name.id}})
    end
  end

  ast_module Expr do
    ast_type Assign, name : Token, value : Expr
    ast_type Binary, left : Expr, operator : Token, right : Expr
    ast_type Call, callee : Expr, paren : Token, arguments : Array(Expr)
    ast_type Comment, body : Token
    ast_type Get, object : Expr, name : Token
    ast_type Grouping, expression : Expr
    ast_type Lambda, params : Array(Token), body : Array(Stmt)
    ast_type Literal, value : LiteralType
    ast_type Logical, left : Expr, operator : Token, right : Expr
    ast_type Set, object : Expr, name : Token, value : Expr
    ast_type Super, keyword : Token, method : Token
    ast_type This, keyword : Token
    ast_type Variable, name : Token
    ast_type Unary, operator : Token, right : Expr
  end

  ast_module Stmt do
    ast_type Block, statements : Array(Stmt)
    ast_type Break, token : Token
    ast_type Class, name : Token, superclass : Expr::Variable?, methods : Array(Function)
    ast_type Expression, expression : Expr
    ast_type Function, name : Token, params : Array(Token), body : Array(Stmt)
    ast_type If, condition : Expr, then_branch : Stmt, else_branch : Stmt?
    ast_type Next, token : Token
    ast_type Print, expression : Expr
    ast_type Return, keyword : Token, value : Expr
    ast_type Var, name : Token, initializer : Expr?
    ast_type While, condition : Expr, body : Stmt
  end
end
