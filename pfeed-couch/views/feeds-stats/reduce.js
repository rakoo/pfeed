function(key, value, rereduce){

var feedHash = {};
var states = ["isUnread", "isRead"];
  for (var i=0,v; v = value[i]; i++) {
        if (typeof v["title"] != "undefined") {
          feedHash["title"] = v["title"];
        }
        for (var j=0,s; s = states[j]; j++) {
          if (typeof v[s] != "undefined") {
            feedHash[s] = (feedHash[s] ||0) + v[s];
          }
        }
  }
return feedHash;
}
