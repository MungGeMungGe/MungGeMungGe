class MgFavorite {
  final int user_seq;
  final int location_seq;

  MgFavorite({
    required this.user_seq,
    required this.location_seq,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_seq': user_seq,
      'location_seq': location_seq,
    };
  }
}
