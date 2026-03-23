class VisionItem {
  String id;
  String imagePath;
  double x;
  double y;
  double width;
  double height;
  double rotation;
  String? caption;
  bool isRemote;
  String? url;

  VisionItem({
    required this.id,
    required this.imagePath,
    required this.x,
    required this.y,
    this.width = 150,
    this.height = 150,
    this.rotation = 0,
    this.caption,
    this.isRemote = false,
    this.url,
  });

  // convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'rotation': rotation,
    'caption': caption,
    'isRemote': isRemote,
    'url': url,
  };

  // ✅ from JSON
  factory VisionItem.fromJson(Map<String, dynamic> json) {
    return VisionItem(
      id: json['id'],
      imagePath: json['imagePath'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      rotation: json['rotation'].toDouble(),
      caption: json['caption'],
      isRemote: json['isRemote'] ?? false,
      url: json['url'],
    );
  }
}
