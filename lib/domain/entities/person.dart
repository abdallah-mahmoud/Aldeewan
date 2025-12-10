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

  Person({
    required this.id,
    required this.role,
    required this.name,
    this.phone,
    required this.createdAt,
  });
}
