function(doc) {
  if (doc.type == 'entry'){
    if (doc.isRead == 'true') {
      state = "isRead";
    } else {
      state = "isUnread";
    }
    emit([state, doc.feed_id], null);
  }
}

