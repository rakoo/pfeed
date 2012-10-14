function(doc) {
  if (doc.type == 'feed'){
    emit(doc._id, {"title": doc.title});
  } else if (doc.type == 'entry') {
    var state;
    if (doc.isRead == 'true') {
      state = "isRead";
    } else { 
      state = "isUnread";
    }
    var hash = {};
    hash[state] = 1
    emit(doc.feed_id, hash);
  }
}
