import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/customer_repository.dart';
import '../data/measurement_repository.dart';
import '../data/order_repository.dart';
import '../models/customer.dart';
import '../models/order.dart';
import 'add_customer_screen.dart';
import 'measurement_screen.dart';
import 'order_list_screen.dart';

// Shows everything about ONE customer. Read-only.
class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  // Always read the NEWEST customer from the repository,
  // because the customer may have been edited.
  Customer get _customer =>
      customerRepository.getById(widget.customer.id) ?? widget.customer;

  // Each button opens a screen, then refreshes this page when we return.
  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customer: _customer),
      ),
    );
    setState(() {});
  }

  Future<void> _openMeasurements() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeasurementScreen(customer: _customer),
      ),
    );
    setState(() {});
  }

  Future<void> _openOrders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderListScreen(customer: _customer),
      ),
    );
    setState(() {});
  }

  // HELPER: one "label ...... value" line.
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // HELPER: a number in inches. 0 means "not taken yet".
  String _inch(double v) => v == 0 ? '-' : '$v inch';

  // HELPER: a small bold title inside a card.
  Widget _subTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // HELPER: a card with a title, an optional button, and content.
  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? buttonText,
    VoidCallback? onButton,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (buttonText != null)
                  TextButton(onPressed: onButton, child: Text(buttonText)),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  // The measurement lines (or a message if none are saved).
  List<Widget> _measurementRows() {
    final m = measurementRepository.getForCustomer(_customer.id);

    if (m == null) {
      return [const Text('No measurements saved yet.')];
    }

    return [
      _subTitle('Kameez'),
      _row('Length', _inch(m.kameezLength)),
      _row('Chest', _inch(m.chest)),
      _row('Waist', _inch(m.waist)),
      _row('Shoulder', _inch(m.shoulder)),
      _row('Sleeve', _inch(m.sleeve)),
      _row('Neck', _inch(m.neck)),
      _row('Daman width', _inch(m.daman)),
      _row('Collar', m.collarStyle),
      _row('Daman type', m.damanType),
      _row('Side pockets', '${m.sidePockets}'),
      _row('Front pocket', m.frontPocket ? 'Yes' : 'No'),
      _subTitle('Shalwar'),
      _row('Length', _inch(m.shalwarLength)),
      _row('Waist', _inch(m.shalwarWaist)),
      _row('Pancha', _inch(m.pancha)),
      _row('Shalwar pocket', m.shalwarPocket ? 'Yes' : 'No'),
      // Show notes only if the tailor wrote something.
      if (m.notes.isNotEmpty) ...[
        _subTitle('Notes'),
        Text(m.notes),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;
    final orders = orderRepository.getForCustomer(customer.id);

    // Money the customer still owes (delivered orders are counted as paid).
    double due = 0;
    for (final o in orders) {
      if (o.status != OrderStatus.delivered) {
        due += o.balance;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit customer',
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 1. Customer information.
          _section(
            title: 'Customer',
            icon: Icons.person,
            children: [
              _row('Name', customer.name),
              _row('Phone', customer.phone),
              _row('Address', customer.address.isEmpty ? '-' : customer.address),
            ],
          ),

          // 2. Measurements.
          _section(
            title: 'Measurements',
            icon: Icons.straighten,
            buttonText: 'Edit',
            onButton: _openMeasurements,
            children: _measurementRows(),
          ),

          // 3. Orders.
          _section(
            title: 'Orders (${orders.length})',
            icon: Icons.receipt_long,
            buttonText: 'Open',
            onButton: _openOrders,
            children: [
              _row('Balance to collect', 'Rs ${due.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              if (orders.isEmpty) const Text('No orders yet.'),
              ...orders.map(
                (o) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(o.dressType),
                  subtitle: Text(
                    'Delivery: ${DateFormat('dd MMM yyyy').format(o.deliveryDate)}',
                  ),
                  trailing: Text(o.status.label),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}