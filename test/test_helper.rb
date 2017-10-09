$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "fb_scrape"

require 'webmock/minitest'
require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use!
