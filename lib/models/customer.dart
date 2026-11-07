class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  
  factory Customer.fromMap(Map<String, Object?> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
    );
  }
}