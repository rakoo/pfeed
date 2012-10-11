require 'sinatra'
require 'couchrest'
require 'base64'
require 'pfeed'

DBNAME = "http://localhost:5984/pfeed"

post '/newcontent/:url' do |url|

  Thread.new do
    data = PFeed.parse_and_explode request.body.read, CGI.unescape(url)
    payload = {:docs => data.values.flatten}
    CouchRest.post(DBNAME + "/_bulk_docs", payload)
  end

  204 # We have received the update; processing will be done by someone else, somewhere else.
end
