# FB_Scrape

This gem provides a utility for scraping facebook posts and comments. You will require a facebook app id
to use this gem

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'fb_scrape'
```

And then execute:
```ruby
    $ bundle
```
Or install it yourself as:
```ruby
    $ gem install fb_scrape
```
## Usage

### Getting information about a Facebook page

  ```ruby
    require 'fb_scrape'

    client = FBScrape::Client.new("page_name", "access_token")
    client.init
    puts client.id
    puts client.name
  ```

### Loading all the posts for an Facebook account  

  ```ruby
    require 'fb_scrape'
    client = FBScrape::Client.new("page_name", "access_token", "page_id")
    client.load

    puts client.posts.length
  ```

### Loading a post

  ```ruby
    require 'fb_scrape'

    post = FBScrape::Post.load_from_id(id, access_token)    
    puts post.has_more_comments?

    post.load_all_comments
    puts post.has_more_comments?
  ```

<!---
### Using the CLI

  You can use the CLI to get a dump in JSON of posts and comments

  ```
    gem install fb_scrape

    fb_scrape help

    # load all the posts for an account
    fb_scrape posts --username theusername --access_token access_token

    # load all the comments for a post
    fb_scrape comments --id theid --access_token access_token
  ``` -->

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ongair/ig_scrape.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
