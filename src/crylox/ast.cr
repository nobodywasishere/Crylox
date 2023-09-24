# Macro for defining a module to hold AST types, utilizing the visitor architecture
#
# Portions copied from https://github.com/crystal-lang/crystal/blob/master/src/macros.cr#L64
macro ast_module(name)
  abstract class {{name.id}}
    def accept(visitor : {{name.id}}::Visitor)
    end
  end

  module {{name.id}}::Visitor
  end
end

# Macro for defining an AST type, utilizing the visitor architecture
#
# Portions copied from https://github.com/crystal-lang/crystal/blob/master/src/macros.cr#L64
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
    def visit_{{name.id.downcase}}({{ast_class.id.downcase}} : {{ast_class.id}}::{{name.id}})
      raise Crylox::Exception.new "Undefined visitor method visit_{{name.id.downcase}}.",
        Token.new(:error, "", "", 0, 0)
    end
  end
end

module Crylox
  ast_module Expr
  ast_type Expr, Assign, name : Token, value : Expr
  ast_type Expr, Binary, left : Expr, operator : Token, right : Expr
  ast_type Expr, Call, callee : Expr, paren : Token, arguments : Array(Expr)
  ast_type Expr, Comment, body : Token
  ast_type Expr, Grouping, expression : Expr
  ast_type Expr, Lambda, params : Array(Token), body : Array(Stmt)
  ast_type Expr, Literal, value : LiteralType
  ast_type Expr, Logical, left : Expr, operator : Token, right : Expr
  ast_type Expr, Variable, name : Token
  ast_type Expr, Unary, operator : Token, right : Expr

  ast_module Stmt
  ast_type Stmt, Block, statements : Array(Stmt)
  ast_type Stmt, Break, token : Token
  ast_type Stmt, Expression, expression : Expr
  ast_type Stmt, Function, name : Token, params : Array(Token), body : Array(Stmt)
  ast_type Stmt, If, condition : Expr, then_branch : Stmt, else_branch : Stmt?
  ast_type Stmt, Next, token : Token
  ast_type Stmt, Print, expression : Expr
  ast_type Stmt, Return, keyword : Token, value : Expr
  ast_type Stmt, Var, name : Token, initializer : Expr?
  ast_type Stmt, While, condition : Expr, body : Stmt
end
