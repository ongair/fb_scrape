require "test_helper"

describe "Messages and their replies" do

  it "Can load a message from the payload" do
    payload = { 'id' => '12345', 'message' => 'Hi', :created_time => "2017-03-28T07:21:27+0000", 'from' => { 'id' => '123', 'name' => 'A user' }, 'to' => { 'data' => [{ 'name' => 'Tala', 'id' => '12345' }]}}
    message = FBScrape::Message.new(payload, '12345')
    assert_equal '12345', message.id
    assert_equal 'Hi', message.text
    assert_equal '123', message.from_id
    assert message.is_incoming?
    refute message.is_reply? 
  end
end
