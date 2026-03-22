class Interest {
  final int id;
  final String title;
  final String description;
  final String iconName;
  final String colorHex;
  final List<SubInterest> subs;

  Interest({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.colorHex,
    required this.subs,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    var rawSubs = json['subs'] as List? ?? [];
    return Interest(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? 'help',
      colorHex: json['color_hex'] ?? '0xFF2196F3',
      subs: rawSubs.map((s) => SubInterest.fromJson(s)).toList(),
    );
  }
}

class SubInterest {
  final int id;
  final int interestId;
  final String name;

  SubInterest({
    required this.id,
    required this.interestId,
    required this.name,
  });

  factory SubInterest.fromJson(Map<String, dynamic> json) {
    return SubInterest(
      id: json['id'],
      interestId: json['interest_id'],
      name: json['name'],
    );
  }
}
