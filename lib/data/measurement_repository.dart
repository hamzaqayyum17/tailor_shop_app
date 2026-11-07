import 'package:sqflite/sqflite.dart';
import '../models/measurement.dart';
import 'database_helper.dart';

class MeasurementRepository {

  final List<Measurement> _items = [];

  final List<Measurement> _samples = [];


  Future<void> load() async {
    final db = await DatabaseHelper.database;

    var rows = await db.query('measurements');

    if (rows.isEmpty) {
      for (final m in _samples) {
        await db.insert('measurements', m.toMap());
      }
      rows = await db.query('measurements');
    }

    _items.clear();
    for (final row in rows) {
      _items.add(Measurement.fromMap(row));
    }
  }


  Measurement? getForCustomer(String customerId) {
    for (final m in _items) {
      if (m.customerId == customerId) {
        return m;
      }
    }
    return null;
  }

  void save(Measurement measurement) {
    final index =
        _items.indexWhere((m) => m.customerId == measurement.customerId);
    if (index == -1) {
      _items.add(measurement);
    } else {
      _items[index] = measurement;
    }
    _saveToDb(measurement);
  }

  void deleteForCustomer(String customerId) {
    _items.removeWhere((m) => m.customerId == customerId);
    _deleteFromDb(customerId);
  }

  Future<void> _saveToDb(Measurement measurement) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'measurements',
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _deleteFromDb(String customerId) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'measurements',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
  }
}


final measurementRepository = MeasurementRepository();