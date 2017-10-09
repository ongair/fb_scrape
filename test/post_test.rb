require "test_helper"

describe "Posts and their comments" do

  it "Can load a page by its id" do
    id = "4567890"
    token = "token"

    stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/comments?access_token=#{token}")
      .to_return(status: 200, body: {
        data: [
          {
            created_at: "2017-03-28T07:21:27+0000",
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
            after: "next_cursor"
          }
        }
      }.to_json
    )

    more_stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/comments?access_token=#{token}&limit=15&after=next_cursor")
      .to_return(status: 200, body: {
        data: [
          {
            created_at: "2017-03-28T07:21:27+0000",
            from: {
              name: "Tala",
              id: "087654"
            },
            message: "A reply",
            id: "#{id}_456789"
          }
        ],
        paging: {
          cursors: {
            before: "before_cursor"
          }
        }
      }.to_json
    )

    post = FBScrape::Post.load_from_id(id, token)
    assert_requested stub
    assert_equal 1, post.comments.length
    assert post.has_more_comments?

    post.load_all_comments
    assert_requested more_stub
    assert_equal 2, post.comments.length
    assert !post.has_more_comments?
  end

end
