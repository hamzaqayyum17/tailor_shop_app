import 'package:sqflite/sqflite.dart';
import '../models/order.dart';
import 'customer_repository.dart';
import 'database_helper.dart';

class OrderRepository {
  final List<Order> _orders = [];

  final List<Order> _samples = [];

  Future<void> load() async {
    final db = await DatabaseHelper.database;

    var rows = await db.query('orders');

    if (rows.isEmpty) {
      for (final o in _samples) {
        await db.insert('orders', o.toMap());
      }
      rows = await db.query('orders');
    }

    _orders.clear();
    for (final row in rows) {
      _orders.add(Order.fromMap(row));
    }
  }

  List<Order> getAll() {
    return _orders;
  }

    List<Order> getForCustomer(String customerId) {
    return _orders.where((o) => o.customerId == customerId).toList();
  }
  void add(Order order) {
    _orders.add(order);
    _saveToDb(order);
  }

  void update(Order updated) {
    final index = _orders.indexWhere((o) => o.id == updated.id);
    if (index != -1) {
      _orders[index] = updated;
      _saveToDb(updated);
    }
  }

  void delete(String id) {
    _orders.removeWhere((o) => o.id == id);
    _deleteFromDb('id = ?', [id]);
  }

  void deleteForCustomer(String customerId) {
    _orders.removeWhere((o) => o.customerId == customerId);
    _deleteFromDb('customerId = ?', [customerId]);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Order> todaysDeliveries() {
    final today = DateTime.now();
    return _orders
        .where(
          (o) =>
              _isSameDay(o.deliveryDate, today) &&
              o.status != OrderStatus.delivered,
        )
        .toList();
  }

  int countByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).length;
  }

  double totalEarnings() {
    double total = 0;
    for (final o in _orders) {
      total += o.status == OrderStatus.delivered ? o.price : o.advance;
    }
    return total;
  }

  List<Order> search({String query = '', OrderStatus? status}) {
    final text = query.trim().toLowerCase();

    final result = _orders.where((o) {
      if (status != null && o.status != status) {
        return false;
      }
      if (text.isEmpty) {
        return true;
      }
      final name = customerRepository.getById(o.customerId)?.name ?? '';
      return name.toLowerCase().contains(text) ||
          o.dressType.toLowerCase().contains(text);
    }).toList();

    result.sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));
    return result;
  }

  Future<void> _saveToDb(Order order) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _deleteFromDb(String where, List<Object?> args) async {
    final db = await DatabaseHelper.database;
    await db.delete('orders', where: where, whereArgs: args);
  }
}

final orderRepository = OrderRepository();
