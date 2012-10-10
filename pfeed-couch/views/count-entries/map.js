function(doc) {
  if (doc.type == 'entry'){
    if (doc.isRead == 'true') {
      state = "isRead";
    } else {
      state = "isUnread";
    }
    emit([doc.feed_id, state], null);
  }
}

