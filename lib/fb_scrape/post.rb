require 'json'

class FBScrape::Post

  attr_accessor :id, :created_at, :message, :comments

  def initialize payload
    @comments = []

    if payload
      load_from_payload(payload)
    end
  end

  private
    def load_from_payload payload
      @id = payload["id"]
      @created_at = payload["created_at"]
      @message = payload["message"]
    end
end
