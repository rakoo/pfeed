require 'feedzirra'

module PFeed

  ## Return multiple couch-storable docs based on a feed parsed by
  ## feedzirra
  def self.parse_and_explode_feed url
    require 'base64'

    # parse some useful stuff with feedzirra
    Feedzirra::Feed.add_common_feed_element(:link, :as => :hub, :value => :href, :with =>{:type => :hub})
    Feedzirra::Feed.add_common_feed_element(:id)

    stored_feed = PFeed.list_feeds(:keys => [url], :include_docs => true).first

    # use last-modified info if present
    options = if stored_feed.nil?
                {}
              else
                doc = stored_feed["doc"]
                {
                 :if_none_match => Base64.strict_decode64(doc["etag"]),
                 :if_modified_since => Time.new(doc["last_modified"])
                }
              end
    parsed_feed = Feedzirra::Feed.fetch_and_parse(url, options)

    return if parsed_feed == 304 # No modification; move along
    return if parsed_feed.respond_to? :to_i # An error during retrieve; maybe next time?

    feed_entry = PFeed.base_couch_entry(parsed_feed).merge({
      :type => :feed,
      :description => parsed_feed.description,
      :url => parsed_feed.feed_url,
      :last_modified => parsed_feed.last_modified,
      :etag => Base64.strict_encode64(parsed_feed.etag), # we don't want any fun stuff
      :hub => parsed_feed.hub, # feedzirra can only fetch one value for the moment
    })

    feed_entries = parsed_feed.entries.map do |entry|

      # Here be ruby 1.9 dragons
      content = begin
                  entry.content.encode(Encoding::UTF_8)
                rescue
                  entry.content.force_encoding(Encoding::UTF_8)
                end

      PFeed.base_couch_entry(entry).merge({
        :type => :entry,
        :feed_id => parsed_feed.id,
        :url => entry.url,
        :updated => entry.published,
        :author => entry.author,
        :summary => entry.summary,
        :published => entry.published,
        :updated => entry.updated,
        :categories => entry.categories,
        :_attachments => {
          :content => {
            :content_type => "text/plain",
            :data => Base64.strict_encode64(content)
          }
        }
      })
    end

    {:feed => feed_entry, :entries => feed_entries}
  end

  def self.base_couch_entry source

    id = source.id
    {
      :_id => id,
      :title => source.title,
    }
  end

  # params can be what couchdb views accept
  def self.list_feeds params={}
    feeds = DB.view 'pfeed-couch/list-feeds-by-url', params
    feeds["rows"]
  end

end
