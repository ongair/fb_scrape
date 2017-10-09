require 'httparty'

class FBScrape::Client

  attr_accessor :page_name, :id, :name, :posts

  def initialize(page_name, token_secret, id=nil)
    @page_name = page_name
    @token_secret = token_secret
    @id = id
    @posts = []
  end

  def init
    get_page_id
  end

  def load_posts
    url = "https://graph.facebook.com/v2.10/#{@id}/posts?access_token=#{@token_secret}"
    resp = HTTParty.get(url)

    case resp.code
      when 200
        response = JSON.parse(resp.body)
        data = response["data"]
        @posts = data.collect{ |d| FBScrape::Post.new(d) }
    end
  end

  private
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

end
