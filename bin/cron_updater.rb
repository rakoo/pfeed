require 'feedzirra'
require 'couchrest'
require 'pfeed'

DB = CouchRest.new("http://localhost:5984").database("pfeed")
DBNAME = "http://localhost:5984/pfeed"

feeds_urls = DB.view("pfeed-couch/list-feeds-without-hubs")["rows"].map{|feed| feed["key"]}
exit if feeds_urls.empty?

parsed_feeds = feeds_urls.map{|url| PFeed.parse_and_explode_feed(url).values}.flatten

payload = {:docs => parsed_feeds}
CouchRest.post(DBNAME + "/_bulk_docs", payload)

