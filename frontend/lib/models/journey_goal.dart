class JourneyGoal {
  final String id;
  String title;
  String description;
  String category;
  DateTime deadline;
  bool isCompleted;

  JourneyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.deadline,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'deadline': deadline.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory JourneyGoal.fromJson(Map<String, dynamic> json) => JourneyGoal(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
    deadline: DateTime.parse(json['deadline'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}
