class StickerModel {
  final int id;
  final int userId;
  final String name;
  final String imageUrl;
  final bool isPublic;
  final DateTime createdAt;
  final String? creatorName;

  StickerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.isPublic,
    required this.createdAt,
    this.creatorName,
  });

  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? 'Sticker',
      imageUrl: json['image_url'] ?? '',
      isPublic: json['is_public'] == 1 || json['is_public'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      creatorName: json['creator_name'],
    );
  }
}
