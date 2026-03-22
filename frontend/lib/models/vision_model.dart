class VisionItem {
  String id;
  String imagePath;
  double x;
  double y;
  double width;
  double height;
  double rotation;
  String? caption;

  VisionItem({
    required this.id,
    required this.imagePath,
    required this.x,
    required this.y,
    this.width = 150,
    this.height = 150,
    this.rotation = 0,
    this.caption,
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
  };

  // ✅ from JSON
  factory VisionItem.fromJson(Map<String, dynamic> json) {
    return VisionItem(
      id: json['id'],
      imagePath: json['imagePath'],
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      rotation: json['rotation'],
      caption: json['caption'],
    );
  }
}
