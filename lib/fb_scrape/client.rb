require 'httparty'

class FBScrape::Client

  attr_accessor :page_name, :id, :name, :posts
  GRAPH_VERSION = "2.10"

  def initialize(page_name, token_secret, id=nil)
    @page_name = page_name
    @token_secret = token_secret
    @id = id
    @posts = []
    @loaded_initial = false
    if @id
      load_initial_posts
    end
  end

  def init
    get_page_id
  end


  def load
    while has_more_posts? do
      # load more posts
      load_more_posts
    end
  end

  def has_more_posts?
    @page_info && next_cursor
  end

  private

    def load_initial_posts
      url = "https://graph.facebook.com/v#{GRAPH_VERSION}/#{@id}/posts?access_token=#{@token_secret}"
      resp = HTTParty.get(url)

      case resp.code
        when 200
          response = JSON.parse(resp.body)
          data = response["data"]
          @posts = data.collect{ |d| FBScrape::Post.new(d) }
          @page_info = response["paging"]
          @loaded_initial = true
      end
    end

    def load_more_posts
      url = "https://graph.facebook.com/v#{GRAPH_VERSION}/#{id}/posts?access_token=#{@token_secret}&limit=25&after=#{next_cursor}"
      resp = HTTParty.get(url)

      case resp.code
        when 200
          response = JSON.parse(resp.body)
          more_posts = response["data"].collect { |p| FBScrape::Post.new(p) }
          @posts = @posts.concat(more_posts)
          @page_info = response["paging"]
      end
    end

    def next_cursor
      @page_info["cursors"]["next"]
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

end
