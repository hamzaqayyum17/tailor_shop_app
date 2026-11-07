import 'package:flutter/material.dart';
import '../data/customer_repository.dart';
import '../models/customer.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? _customer;
  const AddCustomerScreen({super.key, this._customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool get _isEditing => widget._customer != null;
  @override
  void initState() {
    super.initState();
    if (widget._customer != null) {
      _nameController.text = widget._customer!.name;
      _phoneController.text = widget._customer!.phone;
      _addressController.text = widget._customer!.address;
    }
  }

  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customer = Customer(
      id: _isEditing
          ? widget._customer!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(), // trim() removes extra spaces
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (_isEditing) {
      customerRepository.update(customer);
    } else {
      customerRepository.add(customer);
    } // save it
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Customer' : 'Add Customer'),),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone, // number keyboard
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                // Address is optional, so no validator.
              ),
              const SizedBox(height: 24),
              // SizedBox with full width makes the button wide.
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
