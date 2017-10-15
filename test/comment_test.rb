require "test_helper"

describe "Posts and their comments" do

  it "Can tell if a comment is a response from a page" do
    comment = FBScrape::Comment.new({ id: '0987654', message: "Hey", 'from' => { 'id' => "123", 'name' => "Tala" } }, nil, "123")
    assert comment.is_page_response?
  end

  it "Can load the replies to a comment" do
    token =  "token"
    id = "123"
    comment = FBScrape::Comment.new({ 'id' => id }, token)

    stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/comments?access_token=#{token}")
      .to_return(status: 200, body: {
        data: [
          {
            created_time: "2017-03-28T07:21:27+0000",
            from: {
              name: "Samuel Wanjala",
              id: '2345678'
            },
            message: "Hi there",
            id: "#{id}_098765"
          }
        ],
        paging: {
          cursors: {
            next: 'next_cursor'
          }
        }
      }.to_json
    )

    more_stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/comments?access_token=#{token}&limit=25&after=next_cursor")
      .to_return(status: 200, body: {
        data: [
          {
            created_time: "2017-03-28T07:21:27+0000",
            from: {
              name: "Samuel",
              id: '63478428932'
            },
            message: "Hi there",
            id: "#{id}_12345"
          }
        ],
        paging: {
          cursors: {
            before: 'before_cursor'
          }
        }
      }.to_json
    )

    comment.load_replies
    assert_requested stub
    assert_equal 1, comment.comments.count
    assert comment.has_more_replies?

    comment.load_all_replies
    assert_requested more_stub
    assert_equal 2, comment.comments.count
  end

end
