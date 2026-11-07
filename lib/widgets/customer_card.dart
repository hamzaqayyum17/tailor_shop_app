import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onMeasurements;
  final VoidCallback onOrders;
  final VoidCallback onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onMeasurements,
    required this.onOrders,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              child: Text(customer.name[0].toUpperCase()),
            ),
            title: Text(
              customer.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${customer.phone}\n${customer.address}'),
            isThreeLine: true,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onMeasurements,
                icon: const Icon(Icons.straighten),
                label: const Text('Measure'),
              ),
              TextButton.icon(
                onPressed: onOrders,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Orders'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}