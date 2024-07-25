class Favorite {
  final String userId;
  final String itemId;

  Favorite({
    required this.itemId, 
    required this.userId, 
  });

  // Create Favorite from JSON
  factory Favorite.fromMap(Map<String, dynamic> json) {
    return Favorite(
      itemId: json['itemId'],
      userId: json['userId'],
    );
  }

  // Convert Favorite to JSON
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'userId': userId,
    };
  }
}
