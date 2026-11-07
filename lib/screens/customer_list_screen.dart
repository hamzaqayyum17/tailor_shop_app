import 'package:flutter/material.dart';
import '../data/customer_repository.dart';
import '../data/measurement_repository.dart';
import '../data/order_repository.dart';
import '../models/customer.dart';
import '../widgets/customer_card.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';
import 'measurement_screen.dart';
import 'order_list_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  // Holds the text typed in the search box.
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({Customer? customer}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customer: customer),
      ),
    );
    setState(() {});
  }

  Future<void> _openDetail(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailScreen(customer: customer),
      ),
    );
    setState(() {});
  }

  void _openMeasurements(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeasurementScreen(customer: customer),
      ),
    );
  }

  void _openOrders(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderListScreen(customer: customer),
      ),
    );
  }

  Future<void> _confirmDelete(Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete customer?'),
        content: Text(
          'Do you want to delete ${customer.name}? '
          'Measurements and orders will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      customerRepository.delete(customer.id);
      measurementRepository.deleteForCustomer(customer.id);
      orderRepository.deleteForCustomer(customer.id);
      setState(() {});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${customer.name} deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The filtered list. Empty search text gives everyone.
    final customers = customerRepository.search(_searchController.text);
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          // Search box.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}), // update while typing
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                // Clear (X) button, only when something is typed.
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

          // The list takes the remaining height.
          Expanded(
            child: customers.isEmpty
                ? Center(
                    child: Text(
                      isSearching ? 'No customer found' : 'No customers yet',
                    ),
                  )
                : ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () => _openDetail(customer),
                        onMeasurements: () => _openMeasurements(customer),
                        onOrders: () => _openOrders(customer),
                        onDelete: () => _confirmDelete(customer),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}