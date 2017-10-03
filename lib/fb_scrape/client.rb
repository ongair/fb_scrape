require 'httparty'

class FBScrape::Client

  attr_accessor :username

  def initialize(username, token_secret)
    @username = username
  end

end
