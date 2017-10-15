require 'httparty'

class FBScrape::Client

  attr_accessor :page_name, :id, :name, :posts

  def initialize(page_name, token_secret, id=nil, limit=nil)
    @page_name = page_name
    @token_secret = token_secret
    @id = id
    @posts = []
    @loaded_initial = false
    @limit = limit
    if @id
      load_initial_posts
    else
      get_page_id
    end
  end

  def load(limit=nil)
    load_initial_posts
    @limit = limit if !@limit.nil?
    while has_more_posts? && is_under_limit? do
      # load more posts
      load_more_posts
    end
  end

  def is_under_limit?
    !is_limited? || @posts.count < @limit
  end

  def is_limited?
    !@limit.nil?
  end

  def has_more_posts?
    @page_info && next_cursor
  end

  private

    def load_initial_posts
      if !@loaded_initial
        url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}/posts?access_token=#{@token_secret}"
        load_posts_from_url url
        @loaded_initial = true
      end
    end

    def load_more_posts
      url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/posts?access_token=#{@token_secret}&limit=25&after=#{next_cursor}"
      load_posts_from_url url
    end

    def load_posts_from_url url
      resp = HTTParty.get(url)
      case resp.code
        when 200
          response = JSON.parse(resp.body)
          more_posts = response["data"].collect { |p| FBScrape::Post.new(p) }
          @posts = @posts.concat(more_posts)
          @page_info = response["paging"]
        when 400
          handle_error(resp)
      end
    end

    def handle_error resp
      response = JSON.parse(resp.body)
      error = response["error"]["message"]
      raise ArgumentError.new(error)
    end

    def next_cursor
      @page_info["cursors"]["after"]
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
          handle_error(resp)          
      end
    end

end
