require 'json'

class FBScrape::Post

  attr_accessor :id, :created_at, :message, :comments, :link

  def initialize payload, page_id=nil, token=nil
    @comments = []
    @page_id = page_id
    @token = token

    if payload
      load_from_payload(payload)
    end
  end

  def self.load_from_id id, access_token, page_id=nil
    post = FBScrape::Post.new({ 'id' => id }, page_id, access_token)
    post.load_comments
    post
  end

  def load_comments
    url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}/comments?access_token=#{@token}"
    load_from_url url
  end

  def has_more_comments?
    @page_info && next_cursor
  end

  def load_all_comments
    while has_more_comments? do
      load_more_comments
    end
  end

  def to_json(*args)
    JSON.pretty_generate({
      id: @id,
      created_at: @created_at,
      message: @message,
      link: @link
    })
  end


  private

    def load_from_url url
      resp = HTTParty.get(url)
      puts "Resp #{resp.body}"
      case resp.code
        when 200
          response = JSON.parse(resp.body)
          @comments = @comments.concat(response["data"].collect{ |c| FBScrape::Comment.new(c, @token, @page_id) })
          @page_info = response["paging"]
        when 400
          response = JSON.parse(resp.body)
          error = response["error"]["message"]
          raise ArgumentError.new(error)
      end
    end

    def load_more_comments
      url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}/comments?access_token=#{@token}&limit=15&after=#{next_cursor}"
      load_from_url url
    end


    def next_cursor
      @page_info["cursors"]["after"]
    end

    def load_from_payload payload
      @id = payload["id"]
      @created_at = payload["created_time"]
      @message = payload["message"]
      @link = payload["link"]
    end
end
