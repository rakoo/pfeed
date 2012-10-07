function(doc) {
  if (doc.type == 'feed'){
    emit(doc.url, null);
  }
};
