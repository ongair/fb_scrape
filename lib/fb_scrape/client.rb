require 'httparty'

class FBScrape::Client

  attr_accessor :page_name, :id, :name, :posts, :conversations

  def initialize(page_name, token_secret, id=nil, limit=nil, load_on_init=true)
    @page_name = page_name
    @token_secret = token_secret
    @id = id
    @posts = []
    @conversations = []
    @loaded_initial = false
    @loaded_initial_conversations = false
    @limit = limit
    @conversations_page_info = nil
    if @id && load_on_init
      load_initial_posts
    elsif !@id
      get_page_id
    end
  end

  def load(limit=nil)
    load_initial_posts
    @limit = limit if limit != @limit

    while has_more_posts? && is_under_limit? do
      # load more posts
      load_more_posts
    end
  end

  def is_under_limit?
    !is_limited? || @posts.count < @limit.to_i
  end

  def is_limited?
    !@limit.nil?
  end

  def has_more_posts?
    @page_info && next_cursor
  end

  def can_load_more_conversations?
    !is_limited? || (@conversations.count < @limit.to_i && has_more_conversations?)
  end

  def has_more_conversations?
    @conversations_page_info && next_conversation_cursor
  end

  def load_conversations(limit=nil)
    load_initial_conversations
    @limit = limit if limit != @limit

    while has_more_conversations? && can_load_more_conversations? do
      load_more_conversations
    end
  end

  private

    def load_initial_conversations
      if !@loaded_initial_conversations
        url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}/conversations?access_token=#{@token_secret}"
        load_conversations_from_url url
        @loaded_initial_conversations = true
      end
    end

    def load_more_conversations
      url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}/conversations?access_token=#{@token_secret}&limit=25&after=#{next_conversation_cursor}"
      load_conversations_from_url url
    end

    def load_initial_posts
      if !@loaded_initial
        url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}/posts?fields=link,message,created_time&access_token=#{@token_secret}"
        load_posts_from_url url
        @loaded_initial = true
      end
    end

    def load_more_posts
      url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/posts?fields=link,message,created_time&access_token=#{@token_secret}&limit=25&after=#{next_cursor}"
      load_posts_from_url url
    end

    def load_conversations_from_url url
      resp = HTTParty.get(url)
      case resp.code
        when 200
          response = JSON.parse(resp.body)
          response['data'].collect { |c| FBScrape::Conversation.new(c['id'], @id, @token_secret, false) }
          @conversations = @conversations.concat(response['data'].collect { |c| FBScrape::Conversation.new(c['id'], @id, @token_secret, false) })
          @conversations_page_info = response["paging"]
        when 400
          handle_error(resp)
      end
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

    def next_conversation_cursor
      @conversations_page_info["cursors"]["after"]
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
