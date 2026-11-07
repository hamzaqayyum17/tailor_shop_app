enum OrderStatus {
  pending('Pending'),
  stitching('Stitching'),
  ready('Ready'),
  delivered('Delivered');

  final String label;
  const OrderStatus(this.label);
}

class Order {
  final String id;
  final String customerId;
  final String dressType;
  final String fabric;
  final double price;
  final double advance;
  final DateTime deliveryDate;
  final OrderStatus status;

  Order({
    required this.id,
    required this.customerId,
    required this.dressType,
    required this.fabric,
    required this.price,
    required this.advance,
    required this.deliveryDate,
    required this.status,
  });

  double get balance => price - advance;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'dressType': dressType,
      'fabric': fabric,
      'price': price,
      'advance': advance,
      'deliveryDate': deliveryDate.toIso8601String(),
      'status': status.name,
    };
  }

  factory Order.fromMap(Map<String, Object?> map) {
    return Order(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      dressType: map['dressType'] as String,
      fabric: map['fabric'] as String,
      price: (map['price'] as num).toDouble(),
      advance: (map['advance'] as num).toDouble(),
      deliveryDate: DateTime.parse(map['deliveryDate'] as String),
      status: OrderStatus.values.byName(map['status'] as String),
    );
  }
}