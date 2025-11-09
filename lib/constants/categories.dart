import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<Category> categories = [
  Category(id: 'eatout', name: 'Eat out', icon: '🍔', color: Colors.red),
  Category(id: 'transport', name: 'Transport', icon: '🚗', color: Colors.blue),
  Category(id: 'shopping', name: 'Shopping', icon: '🛍️', color: Colors.purple),
  Category(
    id: 'entertainment',
    name: 'Entertainment',
    icon: '🎮',
    color: Colors.orange,
  ),
  Category(
    id: 'bills',
    name: 'Bills & Utilities',
    icon: '💡',
    color: Colors.yellow,
  ),
  Category(id: 'salary', name: 'Salary', icon: '💼', color: Colors.green),
  Category(id: 'travel', name: 'Travel', icon: '✈️', color: Colors.teal),
];
