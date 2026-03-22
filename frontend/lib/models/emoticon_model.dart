class EmoticonModel {
  final String face;
  final String category;
  final bool isCustom;
  final DateTime? createdAt;

  const EmoticonModel({
    required this.face,
    required this.category,
    this.isCustom = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'face': face,
    'category': category,
    'isCustom': isCustom,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory EmoticonModel.fromJson(Map<String, dynamic> json) => EmoticonModel(
    face: json['face'],
    category: json['category'],
    isCustom: json['isCustom'] ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
  );
}

class RecentEmoticon {
  final EmoticonModel emoticon;
  final DateTime copiedAt;

  const RecentEmoticon({required this.emoticon, required this.copiedAt});

  Map<String, dynamic> toJson() => {
    'emoticon': emoticon.toJson(),
    'copiedAt': copiedAt.toIso8601String(),
  };

  factory RecentEmoticon.fromJson(Map<String, dynamic> json) => RecentEmoticon(
    emoticon: EmoticonModel.fromJson(json['emoticon']),
    copiedAt: DateTime.parse(json['copiedAt']),
  );

  String get timeAgo {
    final diff = DateTime.now().difference(copiedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
