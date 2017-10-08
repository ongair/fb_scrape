require "test_helper"

describe "Clients" do

  it "Can get the page id from the name" do

    page_name = "ongairdemo"
    oauth_token = "token"

    stub = stub_request(:get, "https://graph.facebook.com/#{page_name}")
      .to_return(status: 200, body: {
        name: "Tala Kenya",
        id: '12345'
      }.to_json)

    client = FBScrape::Client.new(page_name, oauth_token)
    client.init

    assert_equal client.id, '12345'
    assert_equal client.name, 'Tala Kenya'
  end

end
