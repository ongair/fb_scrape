require 'httparty'

class FBScrape::Client

  attr_accessor :page_name, :id, :name

  def initialize(page_name, token_secret)
    @page_name = page_name
    @token_secret = token_secret
  end

  def init
    get_page_id
  end

  def get_page_id
    url = "https://graph.facebook.com/#{@page_name}?access_token=#{@token_secret}"
    resp = HTTParty.get(url)

    case resp.code
      when 200
        response = JSON.parse(resp.body)
        @name = response["name"]
        @id = response["id"]
      when 400
        response = JSON.parse(resp.body)
        error = response["error"]["message"]
        raise ArgumentError.new(error)
    end
  end

  def load_posts

  end

end
