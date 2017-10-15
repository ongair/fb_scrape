require 'json'

class FBScrape::Post

  attr_accessor :id, :created_at, :message, :comments

  def initialize payload
    @comments = []

    if payload
      load_from_payload(payload)
    end
  end

  def self.load_from_id id, access_token
    post = FBScrape::Post.new({ 'id' => id })
    post.load_comments(access_token)
    post
  end

  def load_comments token
    @token = token
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
    JSON.generate({
      id: @id,
      created_at: @created_at,
      message: @message
    })
  end


  private

    def load_from_url url
      resp = HTTParty.get(url)

      case resp.code
        when 200
          response = JSON.parse(resp.body)
          @comments = @comments.concat(response["data"].collect{ |c| FBScrape::Comment.new(c) })
          @page_info = response["paging"]
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
    end
end
