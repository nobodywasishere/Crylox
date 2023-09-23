require "../spec_helper"

describe Crylox::Expr::Printer do
  it "prints an AST" do
    stmt = Crylox::Stmt::Expression.new(
      Crylox::Expr::Binary.new(
        Crylox::Expr::Unary.new(
          Crylox::Token.new(:minus, "-", nil, 1, 1),
          Crylox::Expr::Literal.new(123)
        ),
        Crylox::Token.new(:star, "*", nil, 1, 1),
        Crylox::Expr::Grouping.new(
          Crylox::Expr::Literal.new(45.67)
        )
      )
    )

    Crylox::Expr::Printer.print([stmt]).should eq("(* (- 123.0) (group 45.67))")
  end
end
