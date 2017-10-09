require 'json'

class FBScrape::Comment

  attr_accessor :id, :created_at, :from_name, :from_id, :message, :comments

  def initialize(payload, access_token=nil, page_id=nil)
    @comments = []
    @access_token = access_token
    @page_id = page_id
    load_from_payload payload
  end

  def is_page_response?
    @page_id == @from_id
  end

  def load_replies access_token=nil
    @access_token = access_token if access_token
    url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}/comments?access_token=#{@access_token}"
    load_from_url url
  end

  def has_more_replies?
    @page_info && next_cursor
  end

  def load_all_replies
    while has_more_replies? do
      load_more_replies
    end
  end

  private

    def next_cursor
      @page_info["cursors"]["next"]
    end

    def load_more_replies
      url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}/comments?access_token=#{@access_token}&limit=25&after=next_cursor"
      load_from_url url
    end

    def load_from_url url

      resp = HTTParty.get(url)

      case resp.code
        when 200
          response = JSON.parse(resp)
          @comments = @comments.concat(response["data"].collect{ |c| FBScrape::Comment.new(c, @access_token, @page_id) })
          @page_info = response["paging"]
      end
    end

    def load_from_payload payload
      if payload
        @id =  payload['id']
        @created_at = payload['created_at']
        @message = payload['message']

        if payload['from']
          @from_name = payload['from']['name']
          @from_id = payload['from']['id']
        end
      end
    end
end
