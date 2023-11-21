class Article{
  int id;
  int itemId;
  int? quantity;
  DateTime? taken;
  DateTime? canceled;

  Article({required this.id, required this.itemId, this.quantity, this.taken, this.canceled});

  /// remaining, canceled, then taken articles
  static int compare(Article a, Article b){
    //taken last
    if(a.taken != null){
      if(b.taken != null) return 0;
      return 1;
    }
    if(b.taken != null) return -1;

    // canceled before taken
    if(a.canceled != null){
      if(b.canceled != null) return 0;
      return 1;
    }
    if(b.canceled != null) return 1;

    // at top, remaining in list
    return 0;
  }

  int compareTo(Article other) => compare(this, other);
}