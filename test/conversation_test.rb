require "test_helper"

describe "Conversation threads within the inbox" do

  it "Can load a conversation by id" do
    id = "12345"
    page_id = "page_id"
    token = "09876"

    stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}?access_token=#{token}&fields=messages{message,to,from}")
      .to_return(status: 200, body: {
        messages: {
          data: [
            {
              message: "Your debit card seems to be okay and active",
              to: {
                data: [
                  {
                    name: "Customer",
                    id: "customer_id"
                  }
                ]
              },
              from: {
                id: "page_id",
                name: "Page"
              },
              id: "message_id_1",
              created_time: "2017-11-28T18:39:05+0000"
            },
            {
              message: "Ok let me try",
              to: {
                data: [
                  {
                    name: "Page",
                    id: "page_id"
                  }
                ]
              },
              from: {
                id: "customer_id",
                name: "Customer"
              },
              id: "message_id_2",
              created_time: "2017-11-28T18:40:06+0000"
            }
          ]
        }
      }.to_json
    )

    conversation = FBScrape::Conversation.new(id, page_id, token)

    assert_equal id, conversation.id
    assert_requested stub
    assert_equal 2, conversation.messages.count
  end

end
