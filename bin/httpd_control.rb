require 'sinatra'
require 'trollop'
require 'json'
require 'couchrest'
require 'pfeed'

set :port, 9494
set :host, 'localhost'

DBNAME = "http://localhost:5984/pfeed"
DB = CouchRest.new("http://localhost:5984").database("pfeed")

get '/list_feeds' do
  content_type :json

  JSON.dump(PFeed.list_feeds)
end

post '/add_feed' do
  content_type :json

  url = params["url"]
  existing_rows = PFeed.list_feeds(:keys => [url], :include_docs => true)
  if existing_rows.size == 1 and existing_rows.first["key"] == url
    doc = existing_rows.first["doc"]
  else
    if (exploded_feed = PFeed.parse_and_explode_feed url)
      payload = {:docs => exploded_feed.values.flatten}
      CouchRest.post(DBNAME + "/_bulk_docs", payload)

      doc = exploded_feed[:feed]
    else
      doc = {:error => "error while parsing #{url}"}
    end
  end

  JSON.dump doc
end
