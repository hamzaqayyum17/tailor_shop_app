import 'package:flutter/material.dart';
import '../data/customer_repository.dart';
import '../data/order_repository.dart';
import '../models/order.dart';
import '../widgets/order_card.dart';
import 'add_order_screen.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}
class _AllOrdersScreenState extends State<AllOrdersScreen> {
  final _searchController = TextEditingController();

  OrderStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openOrder(Order order) async {
    final customer = customerRepository.getById(order.customerId);
    if (customer == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrderScreen(customer: customer, order: order),
      ),
    );
    setState(() {});
  }

  Widget _chip(String label, OrderStatus? status) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedStatus == status,
        onSelected: (_) => setState(() => _selectedStatus = status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = orderRepository.search(
      query: _searchController.text,
      status: _selectedStatus,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}), // update while typing
              decoration: InputDecoration(
                hintText: 'Search customer or dress type',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),

                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _chip('All', null),
                ...OrderStatus.values.map((s) => _chip(s.label, s)),
              ],
            ),
          ),

          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('No orders found'))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final customer = customerRepository.getById(
                        order.customerId,
                      );
                      return OrderCard(
                        order: order,
                        customerName: customer?.name ?? 'Unknown',
                        onTap: () => _openOrder(order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
