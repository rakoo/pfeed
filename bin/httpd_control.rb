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

## params needed:
## * url : a url-encoded url

post '/add_feed' do
  content_type :json

  url = CGI.unescape params["url"]
  existing_rows = PFeed.list_feeds(:keys => [url], :include_docs => true)
  if existing_rows.size == 1 and existing_rows.first["key"] == url
    doc = existing_rows.first["doc"]
  else
    if (exploded_feed = PFeed.fetch_and_parse_explode url)
      payload = {:docs => exploded_feed.values.flatten}
      RestClient.post(DBNAME + "/_bulk_docs", JSON.dump(payload), :content_type => :json)

      doc = exploded_feed[:feed]

      unless doc[:hub].nil?
        # There's a hub ! Subscribe to it
        params = {
          "hub.callback" => "http://otokar.krakotz.co.cc:80/subscribe/#{CGI.escape(url)}",
          "hub.mode" => "subscribe",
          "hub.topic" => doc[:url],
          "hub.verify" => "sync"
        }

        RestClient.post doc[:hub], :params => params
      end

    else
      doc = {:error => "error while parsing #{url}"}
    end
  end

  JSON.dump doc
end
