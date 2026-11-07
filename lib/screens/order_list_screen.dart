import 'package:flutter/material.dart';
import '../data/order_repository.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../widgets/order_card.dart';
import 'add_order_screen.dart';

// Shows all orders of ONE customer.
class OrderListScreen extends StatefulWidget {
  final Customer customer;

  const OrderListScreen({super.key, required this.customer});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  // Same idea as the customer form: no order = new, order = edit.
  Future<void> _openForm({Order? order}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddOrderScreen(customer: widget.customer, order: order),
      ),
    );
    setState(() {}); // refresh when we come back
  }

  @override
  Widget build(BuildContext context) {
    final orders = orderRepository.getForCustomer(widget.customer.id);

    return Scaffold(
      appBar: AppBar(title: Text('Orders: ${widget.customer.name}')),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  onTap: () => _openForm(order: order),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
}