import 'package:flutter/foundation.dart';

class SupplierDashboardProvider with ChangeNotifier {
  bool _isLoading = false;
  int _totalSuppliers = 0;
  double _totalRevenue = 0.0;
  int _totalPersonnel = 0;
  int _pendingOrders = 0;
  int _lowStockItems = 0;
  List<ActivityItem> _recentActivities = [];

  bool get isLoading => _isLoading;
  int get totalSuppliers => _totalSuppliers;
  double get totalRevenue => _totalRevenue;
  int get totalPersonnel => _totalPersonnel;
  int get pendingOrders => _pendingOrders;
  int get lowStockItems => _lowStockItems;
  List<ActivityItem> get recentActivities => _recentActivities;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock data
    _totalSuppliers = 8;
    _totalRevenue = 45280.50;
    _totalPersonnel = 47;
    _pendingOrders = 12;
    _lowStockItems = 8;

    _recentActivities = [
      ActivityItem(
        type: ActivityType.order,
        title: 'New order received',
        subtitle: 'Downtown Restaurant - #ORD-7842',
        time: '2 min ago',
      ),
      ActivityItem(
        type: ActivityType.personnel,
        title: 'Team member added',
        subtitle: 'Sarah Johnson joined Riverside Cafe',
        time: '1 hour ago',
      ),
      ActivityItem(
        type: ActivityType.inventory,
        title: 'Low stock alert',
        subtitle: 'Organic tomatoes running low',
        time: '3 hours ago',
      ),
      ActivityItem(
        type: ActivityType.system,
        title: 'System update',
        subtitle: 'New features available',
        time: '5 hours ago',
      ),
      ActivityItem(
        type: ActivityType.order,
        title: 'Order completed',
        subtitle: 'Central Kitchen - #ORD-7841',
        time: '1 day ago',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void refreshData() {
    loadDashboardData();
  }
}

class ActivityItem {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String time;

  ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

enum ActivityType {
  order,
  inventory,
  personnel,
  system,
}
