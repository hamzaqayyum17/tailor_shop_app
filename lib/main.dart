import 'package:flutter/material.dart';
import 'data/customer_repository.dart';
import 'data/database_helper.dart';
import 'data/order_repository.dart';
import 'screens/home_screen.dart';
import 'data/measurement_repository.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.database;
  await customerRepository.load();
  await orderRepository.load();
  await measurementRepository.load();   
  debugPrint('Database opened, data loaded');

  runApp(const TailorShopApp());
}

class TailorShopApp extends StatelessWidget {
  const TailorShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailor Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}