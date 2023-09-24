class Crylox::Exception < Exception
  getter token : Token

  def initialize(message, @token : Token)
    super message
  end
end
