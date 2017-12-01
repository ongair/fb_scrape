class FBScrape::Message
  attr_accessor :id, :created_at, :from_name, :from_id, :text, :reply_id, :to_id, :to_name


  def initialize(payload, page_id=nil)
    @page_id = page_id
    
    @id = payload['id']
    @text = payload['message']
    @created_at = payload['created_time']

    @from_id = payload['from']['id']
    @from_name = payload['from']['name']
    @to_id = payload['to']['data'].first['id']
    @to_name = payload['to']['data'].first['name']
  end

  def is_incoming?
    @to_id == @page_id
  end

  def is_reply?
    !is_incoming?
  end
end
