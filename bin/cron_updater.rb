require 'feedzirra'
require 'couchrest'
require 'pfeed'

DB = CouchRest.new("http://localhost:5984").database("pfeed")
DBNAME = "http://localhost:5984/pfeed"

feeds_urls = DB.view("pfeed-couch/list-feeds-without-hubs")["rows"].map{|feed| feed["key"]}
exit if feeds_urls.empty?

parsed_feeds = feeds_urls.map do |url|
  modified_bits = PFeed.fetch_and_parse_explode(url)
  modified_bits.nil? ? nil : modified_bits.values
end.compact.flatten

payload = {:docs => parsed_feeds}
CouchRest.post(DBNAME + "/_bulk_docs", payload)

