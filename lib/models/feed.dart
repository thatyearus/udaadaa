import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/models/reaction.dart';

class Feed {
  Feed({
    this.id,
    required this.userId,
    this.createdAt,
    required this.review,
    required this.type,
    required this.imagePath,
    this.imageUrl,
    this.profile,
    this.reaction,
  });

  final String? id;
  final String userId;
  final DateTime? createdAt;
  final String review;
  final String type;
  final String imagePath;
  final String? imageUrl;
  final Profile? profile;
  final List<Reaction>? reaction;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'review': review,
      'type': type,
      'image_path': imagePath,
    };
  }

  Feed.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String,
        userId = map['user_id'] as String,
        createdAt = DateTime.parse(map['created_at'] as String),
        review = map['review'] as String,
        type = map['type'] as String,
        imagePath = map['image_path'] as String,
        imageUrl = map['image_url'] as String,
        profile = Profile.fromMap(map: map['profiles']),
        reaction = map['reactions'] != null
            ? (map['reactions'] as List)
                .map((item) =>
                    Reaction.fromMap(map: item as Map<String, dynamic>))
                .toList()
            : [];

  Feed copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    String? review,
    String? type,
    String? imagePath,
    String? imageUrl,
    Profile? profile,
    List<Reaction>? reaction,
  }) {
    return Feed(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      review: review ?? this.review,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      profile: profile ?? this.profile,
      reaction: reaction ?? this.reaction,
    );
  }
}
