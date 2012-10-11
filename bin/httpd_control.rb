require 'sinatra'
require 'json'
require 'rest-client'
require 'pfeed'

set :port, 9494
set :host, 'localhost'

DBNAME = "http://localhost:5984/pfeed"

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
    if (exploded_feed = PFeed.fetch_and_parse_explode url)
      payload = {:docs => exploded_feed.values.flatten}
      RestClient.post(DBNAME + "/_bulk_docs", JSON.dump(payload), :content_type => :json)

      doc = exploded_feed[:feed]
    else
      doc = {:error => "error while parsing #{url}"}
    end
  end

  JSON.dump doc
end
