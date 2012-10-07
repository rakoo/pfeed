require 'feedzirra'

module PFeed

  ## Return multiple couch-storable docs based on a feed parsed by
  ## feedzirra
  def self.parse_and_explode_feed url
    require 'base64'

    Feedzirra::Feed.add_common_feed_element(:link, :as => :hub, :value => :href, :with =>{:type => :hub})
    Feedzirra::Feed.add_common_feed_element(:id)

    parsed_feed = Feedzirra::Feed.fetch_and_parse(url)

    feed_entry = PFeed.base_couch_entry(parsed_feed).merge({
      :type => :feed,
      :description => parsed_feed.description,
      :url => parsed_feed.feed_url,
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
        :url => entry.url,
        :updated => entry.published,
        :author => entry.author,
        :summary => entry.summary,
        :published => entry.published,
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

    id = source.id || (source.respond_to?(:feed_url) ? source.feed_url : source.url)
    {
      :_id => id,
      :feed_id => source.id,
      :title => source.title,
    }
  end
end
