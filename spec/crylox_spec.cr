require "./spec_helper"

describe Crylox do
  it "interprets code" do
    Crylox.execute("1 + 1;").should eq(2)
    Crylox.execute("true xor true;").should eq(true)
    Crylox.execute("\"a\" + \"b\";").should eq("ab")
  end

  it "interprets for loops" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    Crylox.execute(stdout, stderr) {
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

      print a + b;
      b;
      LOX
    }.should eq(13)

    stderr.to_s.should eq("")
    stdout.to_s.should eq("26.0\n")
  end

  it "allows defining methods" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    Crylox.execute(stdout, stderr) {
      <<-LOX
      fun say_hi(first, last) {
        "Hi, " + first + " " + last + "!";
      }

      print say_hi("how are", "you");
      say_hi("<your name", "here>");
      LOX
    }.should eq("Hi, <your name here>!")

    stderr.to_s.should eq("")
    stdout.to_s.should eq("\"Hi, how are you!\"\n")
  end

  it "closures" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    Crylox.execute(stdout, stderr) {
      <<-LOX
      fun make_counter() {
        var i = 0;
        fun count() {
          i = i + 1;
          print i;
        }

        count;
      }

      var counter = make_counter();
      counter();
      counter();
      counter();
      counter();
      LOX
    }

    stderr.to_s.should eq("")
    stdout.to_s.should eq("1.0\n2.0\n3.0\n4.0\n")
  end
end
