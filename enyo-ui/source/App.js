enyo.kind({
  name: "App",
  kind: "Panels",
  classes: "panels-app-panels enyo-unselectable enyo-fit",
  arrangerKind: "CollapsingArranger",
  components: [
    {layoutKind: "FittableRowsLayout", components: [
      {kind: "onyx.Toolbar", components: [
        {name: "refreshButton", kind: "onyx.Button", fit: true, content: "Refresh", ontap: "refreshListFeeds"},
      ]},
      {name: "feedList", kind: "List", multiSelect: false, touch: true, onSetupItem: "setupFeedItem", components: [
        {name: "feed", classes: "list-feed-item enyo-border-box", style: "padding: 10px", ontap: "feedItemTap", components: [
          {name: "feedCountUnread", tag: "span", style: "float: right; color: lightgrey;"},
          {name: "feedTitle", classes: "list-feed-title"},
          {name: "feedId", style: "color: lightgrey", showing: false} // just hold the value
        ]}
      ]},
    ]},
    {fit: true, layoutKind: "FittableRowsLayout", components: [
      {name: "entryList", kind: "List", fit: true, onSetupItem: "setupEntryItem", touch: true, components: [
        {name: "entry", classes: "list-entry-item enyo-border-box", ontap: "displayFullEntry", components: [
          {name: "entryDate", style: "float: right; color: lightgrey;"},
          {name: "entryTitle", classes: "list-entry-title"},
          {name: "entryContent", classes: "list-entry-content", showing: false},
        ]}
      ]},
    ]},
    {fit: true, layoutKind: "FittableRowsLayout", components: [
      {name: "fullView", style: "color: blue", classes: "full-view enyo-fit", allowHtml: true}
    ]},
    {name: "model", kind: "PFeedAccessor", onResultsListFeeds: "displayListFeeds", onResultsListEntries: "displayListEntries", onResultEntryContentSummary: "displayContentSummary"}
  ],
  feeds: [],
  entries: [],
  rendered: function() {
    this.inherited(arguments);
    this.refreshListFeeds();
  },
  refreshListFeeds: function() {
    this.feeds = [];
    this.$.model.listFeeds();
  },
  setupFeedItem: function(inSender, inEvent) {
    var i = inEvent.index;
    var feed = this.feeds[i];
    this.$.feed.addRemoveClass("onyx-selected", inSender.isSelected(i));
    this.$.feedTitle.setContent(feed.title);
    this.$.feedId.setContent(feed.id);
    this.$.feedCountUnread.setContent("(" + feed.isUnread + ")");
  },
  feedItemTap: function(inSender, inEvent) {
    var id = this.feeds[inEvent.index]["id"];
    this.$.model.listEntries(id);
  },
  displayListFeeds: function(inSender, inResults) {
    for(var i = 0, r; r = inResults[i]; i++) {
      this.feeds[i] = r;
    };
    this.$.feedList.setCount(this.feeds.length);
    this.$.feedList.refresh();
  },

  /* Entries */

  setupEntryItem: function(inSender, inEvent){
    var i = inEvent.index;
    var entry = this.entries[i];
    this.$.entry.addRemoveClass("onyx-selected", inSender.isSelected(i));
    this.$.entryTitle.setContent(entry.title);
    this.$.entryDate.setContent(this.agoDate(entry.published));
    this.$.entryContent.setContent(entry.content);
  },
  displayListEntries: function(inSender, inResults) {
    this.entries = [];
    for(var i = 0, r; r = inResults[i]; i++) {
      this.entries[i] = r;
    };
    this.$.entryList.setCount(this.entries.length);
    this.$.entryList.refresh();
  },

  /* This part is ruthlessly copied from
  * http://webdesign.onyou.ch/2010/08/04/javascript-time-ago-pretty-date/.
  * Thank you !
  */
  agoDate: function(date_str){
    var time_formats = [
      [60, 'just now', 1], // 60
      [120, '1 minute ago', '1 minute from now'], // 60*2
      [3600, 'minutes', 60], // 60*60, 60
      [7200, '1 hour ago', '1 hour from now'], // 60*60*2
      [86400, 'hours', 3600], // 60*60*24, 60*60
      [172800, 'yesterday', 'tomorrow'], // 60*60*24*2
      [604800, 'days', 86400], // 60*60*24*7, 60*60*24
      [1209600, 'last week', 'next week'], // 60*60*24*7*4*2
      [2419200, 'weeks', 604800], // 60*60*24*7*4, 60*60*24*7
      [4838400, 'last month', 'next month'], // 60*60*24*7*4*2
      [29030400, 'months', 2419200], // 60*60*24*7*4*12, 60*60*24*7*4
      [58060800, 'last year', 'next year'], // 60*60*24*7*4*12*2
      [2903040000, 'years', 29030400], // 60*60*24*7*4*12*100, 60*60*24*7*4*12
      [5806080000, 'last century', 'next century'], // 60*60*24*7*4*12*100*2
      [58060800000, 'centuries', 2903040000] // 60*60*24*7*4*12*100*20, 60*60*24*7*4*12*100
    ];
    var time = ('' + date_str).replace(/-/g,"/").replace(/[TZ]/g," ").replace(/^\s\s*/, '').replace(/\s\s*$/, '');
    if(time.substr(time.length-4,1)==".")
      time = time.substr(0,time.length-4);
    var seconds = (new Date - new Date(time)) / 1000;
    var token = 'ago', list_choice = 1;
    if (seconds < 0) {
      seconds = Math.abs(seconds);
      token = 'from now';
      list_choice = 2;
    }
    var i = 0, format;
    while (format = time_formats[i++]) 
      if (seconds < format[0]) {
        if (typeof format[2] == 'string')
          return format[list_choice];
        else
          return Math.floor(seconds / format[2]) + ' ' + format[1] + ' ' + token;
      }
      return time;
  },

  /* Content and Summary */
  displayContentSummary: function(inSender, inResult){
    for (var i=0,e; e=this.entries[i]; i++){
      if(e.id == inResult.id) {
        var newEntry = e;
        if (typeof inResult.content != 'undefined')
          newEntry.content = inResult.content;
        if(typeof inResult.summary != 'undefined')
          newEntry.summary = inResult.summary;
        this.entries.splice(i,1,newEntry);
      }
    }
    this.$.entryList.refresh();
  },

  /* Full entry */
  displayFullEntry: function(inSender, inEvent){
    var entry = this.entries[inEvent.index];
    if (entry.hasContent) {
      this.$.fullView.setContent(entry.content);
    } else if (entry.hasSummary) {
      this.$.fullView.setContent(entry.summary);
    }
  }
});
