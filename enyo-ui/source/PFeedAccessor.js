// A simple component to do a Flickr search.
enyo.kind({
  name: "PFeedAccessor",
  kind: "Component",
  events: {
    onResultsListFeeds: "",
    onResultsListEntries: "",
    onResultEntryContentSummary: ""
  },
  modelUrl: "http://localhost:5984/pfeed/",
  pageSize: 200,
  listFeeds: function(inUrl) {
    var url = inUrl;
    var params = {
      reduce: true,
      group: true,
    };
    return new enyo.Ajax({
      url: this.modelUrl + "_design/pfeed-couch/_view/feeds-stats",
      handleAs: "json",
    }).response(this, "processListFeedsResponse")
      .go(params);
  },
  processListFeedsResponse: function(inSender, inResponse) {
    var resp = [];
    var rows = inResponse.rows ? inResponse.rows : []
    for (var i=0, r; r = rows[i]; i++) {
      resp[i] = {
        id: r.key,
        title: r.value.title,
        isUnread: r.value.isUnread || 0,
        isRead: r.value.isRead || 0
      }
    }

    this.doResultsListFeeds(resp)
    return resp;
  },
  listEntries: function(inFeedId) {
    var params = {
      keys: JSON.stringify([inFeedId]),
      include_docs: true,
    }
    var ajax = new enyo.Ajax({
      url: this.modelUrl + "_design/pfeed-couch/_view/list-entries-by-id",
      handleAs: "json",
    }).response(this, function(inSender, inResponse){
      var rows = inResponse.rows ? inResponse.rows : [];
      var resp = [];
      for (var i=0, r; r=rows[i]; i++){
        doc = r.doc;
        resp.push({
          id: doc._id,
          author: doc.author,
          categories: doc.categories,
          feed_id: doc.feed_id,
          published: doc.published,
          title: doc.title,
          updated: doc.updated,
          url: doc.url,
          hasContent: doc._attachments.content.length > 0,
          hasSummary: doc._attachments.summary.length > 0,
        });
        this.fetchContentSummary(doc._id);
      }
      this.doResultsListEntries(resp);
      return resp;
    });

    return ajax.go(params);

  },
  fetchContentSummary: function(inEntryId) {

    var contentAjax = new enyo.Ajax({
      url: this.modelUrl + encodeURIComponent(inEntryId) + "/" + "content",
      handleAs: "text"
    }).response(this, function(inSender, inResponse){
      this.doResultEntryContentSummary({id: inEntryId, content: inResponse});
    });
    contentAjax.go();

    var summaryAjax = new enyo.Ajax({
      url: this.modelUrl + encodeURIComponent(inEntryId) + "/" + "summary",
      handleAs: "text"
    }).response(this, function(inSender, inResponse){
      var payload = {};
      payload[inEntryId] = {summary: inResponse};
      this.doResultEntryContentSummary({id: inEntryId, summary: inResponse});
    });
    summaryAjax.go();

  }
});
