import 'package:flutter/material.dart';
import 'package:gluttex_personnel/supplier_dashboard_provider.dart';
import 'package:provider/provider.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SupplierDashboardScreen> createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierDashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with User Profile
          _buildAppBar(),
          // Dashboard Content
          _buildDashboardContent(),
        ],
      ),
      floatingActionButton: _buildQuickActionButton(),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      collapsedHeight: 80,
      floating: true,
      pinned: true,
      snap: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[800]!,
                Colors.indigo[900]!,
              ],
            ),
          ),
          child: _buildHeaderContent(),
        ),
        title: const Text(
          'My Businesses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<SupplierDashboardProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  // Welcome Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage Your Businesses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quick Stats Circle
                  _buildQuickStatsCircle(provider),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCircle(SupplierDashboardProvider provider) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            provider.totalSuppliers.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Businesses',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildDashboardContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Overview Cards
            _buildOverviewCards(),
            const SizedBox(height: 24),
            // Performance Chart
            _buildPerformanceChart(),
            const SizedBox(height: 24),
            // Recent Activity & Quick Actions
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Consumer<SupplierDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildOverviewShimmer();
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              title: 'Total Revenue',
              value: '\$${provider.totalRevenue.toStringAsFixed(2)}',
              subtitle: '+12% this month',
              icon: Icons.attach_money,
              color: Colors.green,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
            ),
            _buildStatCard(
              title: 'Active Personnel',
              value: provider.totalPersonnel.toString(),
              subtitle: 'Across all locations',
              icon: Icons.people_alt,
              color: Colors.blue,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[400]!, Colors.blue[600]!],
              ),
            ),
            _buildStatCard(
              title: 'Pending Orders',
              value: provider.pendingOrders.toString(),
              subtitle: 'Need attention',
              icon: Icons.shopping_cart,
              color: Colors.orange,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange[400]!, Colors.orange[600]!],
              ),
            ),
            _buildStatCard(
              title: 'Low Stock Items',
              value: provider.lowStockItems.toString(),
              subtitle: 'Time to reorder',
              icon: Icons.inventory_2,
              color: Colors.red,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red[400]!, Colors.red[600]!],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewShimmer() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  Widget _buildPerformanceChart() {
    return Consumer<SupplierDashboardProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Last 7 Days',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: _buildChart(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(SupplierDashboardProvider provider) {
    // Mock chart data
    final data = [1200, 1800, 1500, 2200, 1900, 2500, 2800];
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (index) {
        final height = (data[index] / maxValue) * 150;
        return Expanded(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 20,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue[400]!,
                      Colors.blue[600]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Text(
                        '\$${data[index]}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[index],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBottomSection() {
    return Consumer<SupplierDashboardProvider>(
      builder: (context, provider, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Activity
            Expanded(
              flex: 2,
              child: _buildRecentActivity(provider),
            ),
            const SizedBox(width: 16),
            // Quick Actions
            Expanded(
              flex: 1,
              child: _buildQuickActions(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity(SupplierDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...provider.recentActivities
              .map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.add_business,
            label: 'Add Business',
            onTap: _addNewBusiness,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.people_alt,
            label: 'Manage Teams',
            onTap: _manageAllTeams,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.analytics,
            label: 'View Reports',
            onTap: _viewReports,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.settings,
            label: 'Settings',
            onTap: _openSettings,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton() {
    return FloatingActionButton(
      onPressed: _showQuickMenu,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add, size: 24),
    );
  }

  void _showQuickMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildQuickActionItem(
                        Icons.add_business, 'New Business', _addNewBusiness),
                    _buildQuickActionItem(
                        Icons.person_add, 'Add Staff', _addNewStaff),
                    _buildQuickActionItem(
                        Icons.inventory, 'Check Stock', _checkStock),
                    _buildQuickActionItem(
                        Icons.receipt, 'New Order', _createOrder),
                    _buildQuickActionItem(
                        Icons.analytics, 'Reports', _viewReports),
                    _buildQuickActionItem(Icons.qr_code, 'Scan QR', _scanQR),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(
      IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue[600], size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Activity helpers
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.order:
        return Colors.green;
      case ActivityType.inventory:
        return Colors.orange;
      case ActivityType.personnel:
        return Colors.blue;
      case ActivityType.system:
        return Colors.purple;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.order:
        return Icons.shopping_cart;
      case ActivityType.inventory:
        return Icons.inventory_2;
      case ActivityType.personnel:
        return Icons.people;
      case ActivityType.system:
        return Icons.settings;
    }
  }

  // Action methods
  void _addNewBusiness() {
    Navigator.pop(context);
    print('Add new business');
  }

  void _manageAllTeams() {
    Navigator.pop(context);
    print('Manage all teams');
  }

  void _viewReports() {
    Navigator.pop(context);
    print('View reports');
  }

  void _openSettings() {
    Navigator.pop(context);
    print('Open settings');
  }

  void _addNewStaff() {
    Navigator.pop(context);
    print('Add new staff');
  }

  void _checkStock() {
    Navigator.pop(context);
    print('Check stock');
  }

  void _createOrder() {
    Navigator.pop(context);
    print('Create order');
  }

  void _scanQR() {
    Navigator.pop(context);
    print('Scan QR');
  }
}
