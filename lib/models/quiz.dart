import 'package:quize_app/models/question.dart';

class Quiz {
  final String id;
  final String title;
  final String categoryId;
  final int timeLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.timeLimit,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON
  factory Quiz.fromJson(String id, Map<String, dynamic> json) {
    return Quiz(
      id: id,
      title: json['title'] as String,
      categoryId: json['categoryId'] as String,
      timeLimit: json['timeLimit'] as int,
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'timeLimit': timeLimit,
      'questions': questions.map((q) => q.toJson()).toList(),
      'updatedAt': DateTime.now(),
    };
  }

  // Copy with optional updated fields
  Quiz copyWith({
    String? title,
    String? categoryId,
    int? timeLimit,
    List<Question>? questions,
  }) {
    return Quiz(
      id: id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
