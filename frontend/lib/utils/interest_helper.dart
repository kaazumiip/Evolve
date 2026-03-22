import 'package:flutter/material.dart';

class InterestHelper {
  static const Map<int, String> categoryNames = {
    1: 'Stem & Tech',
    2: 'Business',
    3: 'Health',
    4: 'Education',
    5: 'Craftmanship',
    6: 'Public Service',
    7: 'Arts & Design',
  };

  static String getCategoryName(int id) {
    return categoryNames[id] ?? 'General';
  }

  static Color getCategoryColor(int id) {
    switch (id) {
      case 1: return Colors.blue;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      case 7: return Colors.pink;
      default: return Colors.teal;
    }
  }

  // Get specific sub-interests based on category ID (Mock data for Profile)
  static List<String> getSpecificInterests(int categoryId) {
    switch (categoryId) {
      case 1: return ['IT', 'Cybersecurity', 'AI'];
      case 2: return ['Management', 'Finance', 'Marketing'];
      case 3: return ['Nursing', 'Psychology'];
      case 4: return ['Teaching', 'Law', 'Politics'];
      case 5: return ['Engineering', 'Mechanics', 'Culinary'];
      case 6: return ['Social Work', 'Policy', 'Advocacy'];
      case 7: return ['UI/UX', 'Graphic Design'];
      default: return ['General'];
    }
  }
}
