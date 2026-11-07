import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/order_repository.dart';
import '../models/customer.dart';
import '../models/order.dart';
import 'measurement_screen.dart';

class AddOrderScreen extends StatefulWidget {
  final Customer customer; // the order belongs to this customer
  final Order? order; // null = new order, not null = edit

  const AddOrderScreen({super.key, required this.customer, this.order});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  // The choices in the dress type dropdown. Add your own anytime.
  static const List<String> _dressTypes = [
    'Shalwar Kameez',
    'Kameez only',
    'Shalwar only',
    'Kurta',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _fabricController = TextEditingController();
  final _priceController = TextEditingController();
  final _advanceController = TextEditingController();

  // Values that are NOT typed text (dropdowns and date).
  String _dressType = _dressTypes.first;
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  OrderStatus _status = OrderStatus.pending;

  bool get _isEditing => widget.order != null;

  // Live balance: reads the two boxes and subtracts.
  double get _balance {
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final advance = double.tryParse(_advanceController.text.trim()) ?? 0;
    return price - advance;
  }

  @override
  void initState() {
    super.initState();
    final old = widget.order;
    if (old != null) {
      _dressType = old.dressType;
      _fabricController.text = old.fabric;
      _priceController.text = old.price.toStringAsFixed(0);
      _advanceController.text = old.advance.toStringAsFixed(0);
      _deliveryDate = old.deliveryDate;
      _status = old.status;
    }
  }

  @override
  void dispose() {
    _fabricController.dispose();
    _priceController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _deliveryDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final order = Order(
      id: _isEditing
          ? widget.order!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),      
      customerId: widget.customer.id,
      dressType: _dressType,
      fabric: _fabricController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      advance: double.tryParse(_advanceController.text.trim()) ?? 0,
      deliveryDate: _deliveryDate,
      status: _status,
    );

    if (_isEditing) {
      orderRepository.update(order);
    } else {
      orderRepository.add(order);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Order' : 'New Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _dressType,
                decoration: const InputDecoration(
                  labelText: 'Dress type',
                  prefixIcon: Icon(Icons.checkroom),
                  border: OutlineInputBorder(),
                ),
                items: _dressTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _dressType = value);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fabricController,
                decoration: const InputDecoration(
                  labelText: 'Fabric (e.g. Wash & Wear, Cotton)',
                  prefixIcon: Icon(Icons.texture),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the fabric';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: 'Rs ',
                  prefixIcon: Icon(Icons.payments),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price = double.tryParse((value ?? '').trim());
                  if (price == null || price <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _advanceController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Advance paid (optional)',
                  prefixText: 'Rs ',
                  prefixIcon: Icon(Icons.savings),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return null; // empty is OK (means 0)
                  final advance = double.tryParse(text);
                  if (advance == null) return 'Enter a valid number';
                  final price =
                      double.tryParse(_priceController.text.trim()) ?? 0;
                  if (advance > price) {
                    return 'Advance cannot be more than the price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Live balance display.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Balance: Rs ${_balance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Delivery date',
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_deliveryDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Status dropdown.
              DropdownButtonFormField<OrderStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: OrderStatus.values
                    .map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _status = value;

                    if (value == OrderStatus.delivered) {
                      _advanceController.text = _priceController.text;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // NEW: opens the measurements that match the chosen dress.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeasurementScreen(
                          customer: widget.customer,
                          dressType: _dressType,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.straighten),
                  label: Text('Measurements for $_dressType'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(_isEditing ? 'Update Order' : 'Save Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
