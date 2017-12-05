class FBScrape::Conversation

  attr_accessor :id, :page_id, :messages, :updated_at

  def initialize id, page_id, token, load_on_init=true
    @id = id
    @page_id = page_id
    @token = token
    @page_info = nil
    @messages = []

    if load_on_init
      load_messages
    end
  end

  def load_messages
    load_initial_messages
  end

  def has_more_messages?
    @page_info && next_cursor
  end

  private

    def next_cursor
      @page_info["cursors"]["after"]
    end

    def load_initial_messages
      url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}?access_token=#{@token}&fields=messages{message,to,from,created_time}"
      load_from_url url
    end

    def load_more_messages
      url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{@id}?access_token=#{@token}&fields=messages{message,to,from,created_time}&limit=25&after=#{next_cursor}"
      load_from_url url
    end

    def load_from_url url
      resp = HTTParty.get(url)
      case resp.code
        when 200
          response = JSON.parse(resp.body)
          @messages = @messages.concat(response['messages']['data'].collect { |m| FBScrape::Message.new(m, @page_id) })
          @page_info = response['messages']['paging']
        when 400
      end
    end
end
