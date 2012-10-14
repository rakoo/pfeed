function(doc) {
if (doc.type == 'entry') {
    emit(doc.feed_id, null);
  }
}
