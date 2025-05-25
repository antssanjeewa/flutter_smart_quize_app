class Category {
  final String id;
  final String name;
  final String description;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
  });

  // Convert from JSON
  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
      id: id,
      name: map['name'] ?? "",
      description: map['description'] ?? "",
      // createdAt:
      //     map['createdAt'] != null
      //         ? DateTime.parse(map['createdAt'])
      //         : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  Category copyWith([String? name, String? description]) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}
