require "test_helper"

class FBScrapeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::FBScrape::VERSION
  end
end
