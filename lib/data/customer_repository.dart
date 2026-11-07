import 'package:sqflite/sqflite.dart';
import '../models/customer.dart';
import 'database_helper.dart';

class CustomerRepository {
  final List<Customer> _customers = [];

  final List<Customer> _samples = [];

  Future<void> load() async {
    final db = await DatabaseHelper.database;

    var rows = await db.query('customers');

    if (rows.isEmpty) {
      for (final c in _samples) {
        await db.insert('customers', c.toMap());
      }
      rows = await db.query('customers');
    }

    _customers.clear();
    for (final row in rows) {
      _customers.add(Customer.fromMap(row));
    }
  }

  List<Customer> getAll() {
    return _customers;
  }

  Customer? getById(String id) {
    for (final c in _customers) {
      if (c.id == id) {
        return c;
      }
    }
    return null;
  }

  List<Customer> search(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) {
      return _customers;
    }

    String clean(String s) => s.replaceAll('-', '').replaceAll(' ', '');
    final cleanText = clean(text);

    return _customers.where((c) {
      return c.name.toLowerCase().contains(text) ||
          clean(c.phone).contains(cleanText);
    }).toList();
  }

  void add(Customer customer) {
    _customers.add(customer);
    _saveToDb(customer);
  }

  void update(Customer updated) {
    final index = _customers.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _customers[index] = updated;
      _saveToDb(updated);
    }
  }

  void delete(String id) {
    _customers.removeWhere((c) => c.id == id);
    _deleteFromDb(id);
  }

  Future<void> _saveToDb(Customer customer) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _deleteFromDb(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}

final customerRepository = CustomerRepository();
