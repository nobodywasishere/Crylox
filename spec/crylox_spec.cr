require "./spec_helper"

describe Crylox do
  it "interprets code" do
    Crylox.execute("1 + 1;").result.should eq(2)
    Crylox.execute("true xor true;").result.should eq(true)
    Crylox.execute("\"a\" + \"b\";").result.should eq("ab")
  end

  it "interprets for loops" do
    res = Crylox.execute {
      <<-LOX
      var a = 0;
      var b = 1;
      var temp = 0;

      for (var i = 0; i < 10; i += 1) {
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
    }

    res.result.should eq(13)
    res.stderr.should eq("")
    res.stdout.should eq("26.0\n")
  end

  it "has break" do
    res = Crylox.execute {
      <<-LOX
      for (var i = 0; i < 5; i += 1) {
        print i;
        break;
      }
      LOX
    }

    res.result.should eq(nil)
    res.stdout.should eq("0.0\n")
    res.stderr.should eq("")
  end

  it "has next" do
    res = Crylox.execute {
      <<-LOX
      for (var i = 0; i < 5; i += 1) {
        next;
        print i;
      }
      LOX
    }

    res.result.should eq(nil)
    res.stdout.should eq("")
    res.stderr.should eq("")
  end

  it "has return in functions" do
    res = Crylox.execute {
      <<-LOX
      fun abc() {
        return ->(){ return; print 1; };

        print 1;
      }

      abc()();
      LOX
    }

    res.result.should eq(nil)
    res.stdout.should eq("")
    res.stderr.should eq("")
  end

  it "allows defining methods" do
    res = Crylox.execute {
      <<-LOX
      fun say_hi(first, last) {
        "Hi, " + first + " " + last + "!";
      }

      print say_hi("how are", "you");
      say_hi("<your name", "here>");
      LOX
    }

    res.result.should eq("Hi, <your name here>!")
    res.stderr.should eq("")
    res.stdout.should eq("\"Hi, how are you!\"\n")
  end

  it "supports closures" do
    res = Crylox.execute {
      <<-LOX
      fun make_counter() {
        var i = 0;
        fun count() {
          i += 1;
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

    res.result.should eq(nil)
    res.stderr.should eq("")
    res.stdout.should eq("1.0\n2.0\n3.0\n4.0\n")
  end

  it "supports lambdas" do
    res = Crylox.execute {
      <<-LOX
      fun thrice(fn) {
        for (var i = 1; i <= 3; i += 1) {
          fn(i);
        }

        thrice;
      }

      thrice(lambda (a) {
        print a;
      })(->(b) {
        print b + 3;
      });

      true;
      LOX
    }

    res.result.should eq(true)
    res.stderr.should eq("")
    res.stdout.should eq("1.0\n2.0\n3.0\n4.0\n5.0\n6.0\n")
  end

  it "resolves variables properly" do
    res = Crylox.execute {
      <<-LOX
      var a = "global";
      {
        fun show_a() {
          print a;
        }

        show_a();
        var a = "block";
        show_a();
      }
      LOX
    }

    res.result.should eq(nil)
    res.stderr.should eq("")
    res.stdout.should eq("\"global\"\n\"global\"\n")
  end
end
