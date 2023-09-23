require "./spec_helper"

describe Crylox do
  it "interprets code" do
    Crylox.execute("1 + 1;").should eq(2)
    Crylox.execute("true xor true;").should eq(true)
    Crylox.execute("\"a\" + \"b\";").should eq("ab")

    Crylox.execute {
      <<-LOX
      var a = 0;
      var b = 1;
      var temp = 0;

      for (var i = 0; i < 10; i = i + 1) {
        b = temp + b;
        temp = a;
        a = b;

        if (a > 10) {
          break;
        }
      }

      b;
      LOX
    }.should eq(13)
  end
end
