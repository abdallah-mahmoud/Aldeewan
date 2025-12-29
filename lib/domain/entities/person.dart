enum PersonRole {
  customer,
  supplier,
}

class Person {
  final String id;
  final PersonRole role;
  final String name;
  final String? phone;
  final DateTime createdAt;
  final bool isArchived;

  Person({
    required this.id,
    required this.role,
    required this.name,
    this.phone,
    required this.createdAt,
    this.isArchived = false,
  });

  Person copyWith({
    String? id,
    PersonRole? role,
    String? name,
    String? phone,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Person(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
