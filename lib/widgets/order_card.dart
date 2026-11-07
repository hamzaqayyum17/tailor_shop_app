import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final String? customerName;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.customerName,
  });

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.stitching:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
    }
  }

  Widget _amount(String label, double value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          'Rs ${value.toStringAsFixed(0)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              if (customerName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        customerName!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.dressType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Fabric: ${order.fabric}'),
              Text(
                'Delivery: ${DateFormat('dd MMM yyyy').format(order.deliveryDate)}',
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _amount('Price', order.price),
                  _amount('Advance', order.advance),
                  _amount(
                    'Balance',
                    order.balance,
                    color: order.balance > 0 ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}