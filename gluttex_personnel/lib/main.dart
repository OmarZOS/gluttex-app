// In your main.dart or app entry point
import 'package:flutter/material.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_personnel/supplier_dashboard_provider.dart';
import 'package:gluttex_personnel/supplier_dashboard_screen.dart';
import 'package:gluttex_personnel/supplier_entities_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => SupplierDashboardProvider()),
        ChangeNotifierProvider(create: (_) => SupplierChangeNotifier()),
        ChangeNotifierProvider(create: (_) => PersonnelProvider()),

        // Add your other providers
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const SupplierEntitiesScreen(), // Start with dashboard
      routes: {
        '/entities': (context) => SupplierEntitiesScreen(),
        // '/dashboard': (context) => const SupplierDashboardScreen(),
      },
    );
  }
}
