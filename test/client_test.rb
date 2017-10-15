require "test_helper"

describe "Clients" do

  it "Can get the page id from the name" do

    page_name = "ongairdemo"
    oauth_token = "token"

    stub = stub_request(:get, "https://graph.facebook.com/#{page_name}?access_token=#{oauth_token}")
      .to_return(status: 200, body: {
        name: "Tala Kenya",
        id: '12345'
      }.to_json)

    client = FBScrape::Client.new(page_name, oauth_token)

    assert_requested stub
    assert_equal client.id, '12345'
    assert_equal client.name, 'Tala Kenya'
  end

  it "Can recover from a token error" do
    page_name = "ongairdemo"
    oauth_token = "token"
    id = "12345"

    stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/posts?fields=link,message,created_time&access_token=#{oauth_token}")
      .to_return(status: 400, body: {
        error: {
          message: "Error validating access token: Session has expired"
        }
      }.to_json)

    assert_raises ArgumentError do
      client = FBScrape::Client.new(page_name, oauth_token, id)
      assert_requested stub
    end
  end

  it "Can load posts for a page" do
    page_name = "ongairdemo"
    auth_token = "token"
    id = "12345"

    stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/posts?fields=link,message,created_time&access_token=#{auth_token}")
      .to_return(status: 200, body: {
        data: [
          {
            created_time: "2017-06-23T06:00:21+0000",
            message: "Its furahi day!",
            id: "post_id"
          }
        ],
        paging: {
          cursors: {
            after: "next_cursor"
          }
        }
      }.to_json
    )

    more_stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/posts?fields=link,message,created_time&access_token=#{auth_token}&limit=25&after=next_cursor")
      .to_return(status: 200, body: {
        data: [
          {
            created_time: "2017-06-23T06:00:21+0000",
            message: "Saturday!",
            id: "post_id_1"
          },
          {
            created_time: "2017-06-23T06:00:21+0000",
            message: "Saturday!",
            id: "post_id_1"
          }
        ],
        paging: {
          cursors: {
            before: "before_cursor"
          }
        }
      }.to_json
    )

    client = FBScrape::Client.new(page_name, auth_token, id)

    assert_requested stub
    assert_equal 1, client.posts.count
    assert client.has_more_posts?
    assert client.is_under_limit?
    refute client.is_limited?

    client.load
    assert_requested more_stub
    assert !client.has_more_posts?
    assert_equal 3, client.posts.count
  end

  it "Can limit the number of posts for a page" do
    auth_token = "token"
    id = "12345"

    stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/posts?fields=link,message,created_time&access_token=#{auth_token}")
      .to_return(status: 200, body: {
        data: [
          {
            created_time: "2017-06-23T06:00:21+0000",
            message: "Its furahi day!",
            id: "post_id"
          },
          {
            created_time: "2017-06-23T06:00:21+0000",
            message: "Its furahi day!",
            id: "post_id_2"
          }
        ],
        paging: {
          cursors: {
            after: "next_cursor"
          }
        }
      }.to_json
    )

    more_stub = stub_request(:get, "https://graph.facebook.com/v#{FBScrape::GRAPH_VERSION}/#{id}/posts?fields=link,message,created_time&access_token=#{auth_token}&limit=25&after=next_cursor")
      .to_return(status: 200, body: {
        data: [
          {
            created_time: "2017-06-23T06:00:21+0000",
            message: "Saturday!",
            id: "post_id_1"
          },
          {
            created_time: "2017-06-23T06:00:21+0000",
            message: "Saturday!",
            id: "post_id_1"
          }
        ],
        paging: {
          cursors: {
            before: "before_cursor"
          }
        }
      }.to_json
    )


    client = FBScrape::Client.new(nil, auth_token, id, 2)
    assert client.is_limited?
    refute client.is_under_limit?
    assert_requested stub
    assert_equal 2, client.posts.count

    client.load(2)
    assert_not_requested more_stub

    client.load
    assert_requested more_stub
  end
end
