require 'sinatra'
require 'couchrest'
require 'base64'
require 'pfeed'

DBNAME = "http://localhost:5984/pfeed"

post '/subscribe/:escaped_url' do |escaped_url|

  Thread.new do
    data = PFeed.parse_and_explode request.body.read, CGI.unescape(escaped_url)
    payload = {:docs => data.values.flatten}
    CouchRest.post(DBNAME + "/_bulk_docs", payload)
  end

  204 # We have received the update; processing will be done by someone else, somewhere else.
end

get '/subscribe/:escaped_url' do |escaped_url|
  challenge = request["hub.challenge"]

  case request["hub.mode"]
  when "subscribe"
    url = CGI.unescape(request["hub.topic"])

    puts "trying to subscribe to #{url}"
    if PFeed.list_feeds(:keys => [url]).size == 0
      404
    else
      challenge
    end
  when "unsubscribe"
    challenge
  end
end
