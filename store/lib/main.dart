import 'package:flutter/material.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:login/screens/login_screen.dart';
import 'package:store/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const InventoryManagerApp());
}

class InventoryManagerApp extends StatelessWidget {
  const InventoryManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppUserNotifier()),
        ChangeNotifierProvider(create: (_) => SupplierChangeNotifier()),
        ChangeNotifierProvider(create: (_) => ProductNotifier()),
        ChangeNotifierProvider(create: (_) => CartChangeNotifier()),
        ChangeNotifierProvider(create: (_) => PersonnelNotifier()),
      ],
      child: MaterialApp(
        title: 'Inventory Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userNotifier = context.watch<AppUserNotifier>();

    if (userNotifier.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return userNotifier.isAuthenticated
        ? const DashboardScreen()
        : const LoginScreen();
  }
}
