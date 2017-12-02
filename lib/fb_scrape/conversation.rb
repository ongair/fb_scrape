class FBScrape::Conversation

  attr_accessor :id, :page_id, :messages, :updated_at

  def initialize id, page_id, token, load_on_init=true
    @id = id
    @page_id = page_id
    @token = token

    if load_on_init
      load_from_url id, token
    end
  end

  # def self.load_from_id id, token, page_id=nil
  #   conversation = FBScrape::Conversation.new(id, page_id)
  #   # conversation.load_from_url id, token
  # end

  private
    def load_from_url id, token

      url = "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}?access_token=#{token}&fields=messages{message,to,from}"
      resp = HTTParty.get(url)
      case resp.code
        when 200
          response = JSON.parse(resp.body)
          @messages = response['messages']['data'].collect { |m| FBScrape::Message.new(m, @page_id) }
        when 400
      end
    end
end
