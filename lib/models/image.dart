class ImageModel {
  final String id;
  final String imgUrl;

  ImageModel({
    required this.id,
    required this.imgUrl,
  });

  ImageModel.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String,
        imgUrl = map['img_url'] as String;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'img_url': imgUrl,
    };
  }

  ImageModel copyWith({
    String? id,
    String? imgUrl,
  }) {
    return ImageModel(
      id: id ?? this.id,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }
}
