require 'json'

class FBScrape::Comment

  attr_accessor :id, :created_at, :from_name, :from_id, :message

  def initialize(payload)
    load_from_payload payload
  end

  private
    def load_from_payload payload
      if payload
        @id =  payload['id']
        @created_at = payload['created_at']
        @message = payload['message']
        @from_name = payload['from']['name']
        @from_id = payload['from']['id']
      end
    end
end
