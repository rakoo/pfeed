require 'sinatra'
require 'json'
require 'couchrest'

COUCHHOST = "http://localhost:5984"
COUCHHOSTREST = CouchRest.new COUCHHOST

DBNAME = "pfeed"
DB = COUCHHOSTREST.database DBNAME

get '/list_feeds' do
  content_type :json

  feeds = DB.view 'pfeed/list_feeds'
  JSON.dump(feeds)
end

post '/add_feed' do
end
