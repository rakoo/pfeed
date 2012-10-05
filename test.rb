require 'pfeed'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class PFeedTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_gets_feeds
    get '/list_feeds'
    assert last_response.ok?
    assert_equal [], JSON.parse(last_response.body)
  end

  def test_it_adds_feed
    add_url = 'http://test.com'
    post '/add_feed', :url => add_url
    assert last_response.ok?
    assert_equal add_url, JSON.parse(last_response.body)

    get '/list_feeds'
    assert last_response.ok?
    assert JSON.parse(last_response.body).contains? add_url
  end

end
