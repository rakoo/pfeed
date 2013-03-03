require 'feedzirra'
require 'couchrest'
require 'pfeed'

DB = CouchRest.new("http://localhost:5984").database("pfeed")
DBNAME = "http://localhost:5984/pfeed"

feeds_urls = DB.view("pfeed-couch/list-feeds-without-hubs")["rows"].map{|feed| feed["key"]}
exit if feeds_urls.empty?

puts "#{feeds_urls.size} feeds to update"

breakpoint = Time.now.to_i
done = 0

parsed_feeds = feeds_urls.map do |url|
  modified_bits = PFeed.fetch_and_parse_explode(url)
  modified_bits.nil? ? nil : modified_bits.values

  done += 1
  if Time.now.to_i - breakpoint >= 2
    breakpoint = Time.now.to_i
    print "#{done} feeds parsed\r"
  end
end.compact.flatten

puts "Done updating all feeds"

payload = {:docs => parsed_feeds}
CouchRest.post(DBNAME + "/_bulk_docs", payload)

