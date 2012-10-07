function(doc) {
  if (doc.type == 'feed'){
    if (typeof doc.hub == "undefined" || doc.hub == null){
    emit(doc.url, null);
    }
  }
};
