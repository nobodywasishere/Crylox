require "../spec_helper"

describe Crylox::Expr::Variable do
  it "exists" do
    Crylox::Expr::Variable.new(Crylox::Token.new(:string, "", "", 1, 1))
  end
end
