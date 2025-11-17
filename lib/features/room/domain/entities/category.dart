import 'package:flutter/material.dart';

class Category {
  final String id;
  final String icon;
  final String name;
  final Color color;

  const Category({
    required this.id,
    required this.icon,
    required this.name,
    required this.color,
  });

  // Convert Category to Map (for JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'color': color.value, // store Color as int
    };
  }

  // Convert Map (JSON) back to Category
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      icon: json['icon'],
      name: json['name'],
      color: Color(json['color']),
    );
  }
}
