require 'sinatra'
require 'trollop'
require 'json'
require 'couchrest'
require 'feedzirra'
require 'pfeed'

module PFeed


  class HttpdControl
    set :port, 9494
    set :host, 'localhost'

    Feedzirra::Feed.add_common_feed_element('hub', :as => :hub, :value => :href, :with =>{:type => "hub"})
    Feedzirra::Feed.add_common_feed_element('id')

    DBNAME = "http://localhost:5984/pfeed"
    DB = CouchRest.new("http://localhost:5984").database("pfeed")

    get '/list_feeds' do
      content_type :json

      JSON.dump(list_feeds)
    end

    post '/add_feed' do
      content_type :json

      url = params["url"]
      existing_rows = list_feeds([url])
      if existing_rows.size == 1 and existing_rows.first["key"] == url
        doc = CouchRest.get "#{DBNAME}/#{CGI.escape(existing_rows.first["id"])}"
      else
        if (feed = Feedzirra::Feed.fetch_and_parse url)
          doc = {
            :_id => feed.id,
            :feed_id => feed.id,
            :title => feed.title,
            :description => feed.description,
            :url => feed.feed_url,
            :hub => feed.hub,
            :type => :feed,
          }

          # store doc
          stored_doc = CouchRest.put(DBNAME + "/#{CGI.escape(doc[:_id])}", doc)

          # store atom header as attachment
          #CouchRest.put DBNAME + "/#{CGI.escape(doc[:_id])}" + "/raw?rev=#{stored_doc["rev"]}", feed, :raw => true
        end
      end

      JSON.dump doc
    end

    helpers do
      def list_feeds ids=nil
        if ids
          feeds = DB.view 'pfeed-couch/list-feeds', {:params => ids}
        else
          feeds = DB.view 'pfeed-couch/list-feeds'
        end
        feeds["rows"]
      end
    end
  end

end
