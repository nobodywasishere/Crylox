require "./Scanner"

module Crylox
  class Crylox
    @hadError : Bool = false

    def main(args : Array(String))
      if args.size > 1
        STDOUT.puts "Usage: crylox [script]"
      elsif args.size == 1
        runFile(args[0])
      else
        runPrompt()
      end
    end

    private def runFile(path : String)
      bytes = File.read(path)
      run(bytes)
      exit(65) if @hadError
    end

    private def runPrompt
      while true
        print "> "
        line = gets("\n")
        unless line.nil?
          run(line)
        else
          break
        end
        @hadError = false
      end
    end

    private def run(source : String)
      scanner = Scanner::Scanner.new(source)
      tokens = scanner.scanTokens()

      tokens.each do |token|
        puts token
      end
    end

    def error(line : Int32, message : String)
      report line, "", message
    end

    private def report(line : Int32, where : String, message : String)
      STDERR.puts "[line #{line}] Error #{where}: #{message}"
    end
  end
end

Crylox::Crylox.new.main(ARGV)
