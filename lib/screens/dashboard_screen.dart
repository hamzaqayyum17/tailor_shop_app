import 'package:flutter/material.dart';
import '../data/customer_repository.dart';
import '../data/order_repository.dart';
import '../models/order.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todays = orderRepository.todaysDeliveries();
    final pending = orderRepository.countByStatus(OrderStatus.pending);
    final stitching = orderRepository.countByStatus(OrderStatus.stitching);
    final ready = orderRepository.countByStatus(OrderStatus.ready);
    final earnings = orderRepository.totalEarnings();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.local_shipping,
                  title: "Today's deliveries",
                  value: '${todays.length}',
                  color: Colors.indigo,
                ),
              ),
              Expanded(
                child: StatCard(
                  icon: Icons.hourglass_empty,
                  title: 'Pending',
                  value: '$pending',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.content_cut,
                  title: 'Stitching',
                  value: '$stitching',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: StatCard(
                  icon: Icons.check_circle_outline,
                  title: 'Ready',
                  value: '$ready',
                  color: Colors.green,
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Total earnings',
                  value: 'Rs ${earnings.toStringAsFixed(0)}',
                  color: Colors.teal,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Text(
              "Today's deliveries",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          if (todays.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No deliveries today'),
            )
          else
            ...todays.map((order) {
              final customer = customerRepository.getById(order.customerId);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.checkroom),
                  title: Text(customer?.name ?? 'Unknown'),
                  subtitle: Text('${order.dressType} • ${order.status.label}'),
                  trailing: Text(
                    'Rs ${order.balance.toStringAsFixed(0)}\nto collect',
                    textAlign: TextAlign.end,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
