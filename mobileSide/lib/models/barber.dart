class Barber {
  final int? id;
  final String name;
  final String phone;
  final bool active;

  Barber({
    this.id,
    required this.name,
    required this.phone,
    this.active = true,
  });

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'active': active,
    };
  }
}
