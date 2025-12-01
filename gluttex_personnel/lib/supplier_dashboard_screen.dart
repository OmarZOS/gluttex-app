import 'package:flutter/material.dart';
import 'package:gluttex_event/supplier_dashboard_provider.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme, colorScheme),
          _buildDashboardContent(theme, colorScheme),
        ],
      ),
      floatingActionButton: _buildQuickActionButton(colorScheme),
    );
  }

  SliverAppBar _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 220,
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
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
            ),
          ),
          child: _buildHeaderContent(theme, colorScheme),
        ),
        title: Text(
          'My Businesses',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  Widget _buildHeaderContent(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<SupplierDashboardProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: colorScheme.onPrimary.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage Your Businesses',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (provider.isLoading)
                          LinearProgressIndicator(
                            backgroundColor:
                                colorScheme.onPrimary.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickStatsCircle(provider, colorScheme),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCircle(
      SupplierDashboardProvider provider, ColorScheme colorScheme) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.onPrimary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: provider.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    provider.totalSuppliers.toString(),
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            'Businesses',
            style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildDashboardContent(
      ThemeData theme, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildOverviewCards(theme, colorScheme),
            const SizedBox(height: 24),
            _buildPerformanceChart(theme, colorScheme),
            const SizedBox(height: 24),
            _buildBottomSection(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<SupplierDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildOverviewShimmer(colorScheme);
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            _buildStatCard(
              title: 'Total Revenue',
              value: '\$${provider.totalRevenue.toStringAsFixed(2)}',
              subtitle: '+12% this month',
              icon: Icons.attach_money_rounded,
              color: Colors.green,
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildStatCard(
              title: 'Active Personnel',
              value: provider.totalPersonnel.toString(),
              subtitle: 'Across all locations',
              icon: Icons.people_alt_rounded,
              color: Colors.blue,
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildStatCard(
              title: 'Pending Orders',
              value: provider.pendingOrders.toString(),
              subtitle: 'Need attention',
              icon: Icons.pending_actions_rounded,
              color: Colors.orange,
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildStatCard(
              title: 'Low Stock Items',
              value: provider.lowStockItems.toString(),
              subtitle: 'Time to reorder',
              icon: Icons.inventory_2_rounded,
              color: Colors.red,
              theme: theme,
              colorScheme: colorScheme,
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
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color,
            ],
          ),
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
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewShimmer(ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPerformanceChart(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<SupplierDashboardProvider>(
      builder: (context, provider, child) {
        return Material(
          borderRadius: BorderRadius.circular(20),
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Performance Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Last 7 Days',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: _buildChart(provider, colorScheme),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChart(
      SupplierDashboardProvider provider, ColorScheme colorScheme) {
    final data = [1200, 1800, 1500, 2200, 1900, 2500, 2800];
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (index) {
              final height = (data[index] / maxValue) * 150;
              return Expanded(
                child: Column(
                  children: [
                    const Spacer(),
                    Tooltip(
                      message: '\$${data[index]}',
                      child: Container(
                        width: 24,
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colorScheme.primary.withOpacity(0.8),
                              colorScheme.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(labels.length, (index) {
            return Expanded(
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomSection(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<SupplierDashboardProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child:
                            _buildRecentActivity(provider, theme, colorScheme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _buildQuickActions(theme, colorScheme),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildRecentActivity(provider, theme, colorScheme),
                      const SizedBox(height: 16),
                      _buildQuickActions(theme, colorScheme),
                    ],
                  );
          },
        );
      },
    );
  }

  Widget _buildRecentActivity(SupplierDashboardProvider provider,
      ThemeData theme, ColorScheme colorScheme) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (provider.recentActivities.isNotEmpty)
                  Text(
                    'View All',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (provider.recentActivities.isEmpty)
              Column(
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 60,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recent activity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              )
            else
              ...provider.recentActivities
                  .map((activity) =>
                      _buildActivityItem(activity, theme, colorScheme))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      ActivityItem activity, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, ColorScheme colorScheme) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.add_business_rounded,
              label: 'Add Business',
              onTap: _addNewBusiness,
              color: colorScheme.primary,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.people_alt_rounded,
              label: 'Manage Teams',
              onTap: _manageAllTeams,
              color: colorScheme.secondary,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.analytics_rounded,
              label: 'View Reports',
              onTap: _viewReports,
              color: colorScheme.tertiary,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: _openSettings,
              color: colorScheme.onSurface.withOpacity(0.6),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(ColorScheme colorScheme) {
    return FloatingActionButton(
      onPressed: _showQuickMenu,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }

  void _showQuickMenu() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
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
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose an action to get started',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildQuickActionItem(
                      Icons.add_business_rounded,
                      'New Business',
                      _addNewBusiness,
                      colorScheme.primary,
                    ),
                    _buildQuickActionItem(
                      Icons.person_add_rounded,
                      'Add Staff',
                      _addNewStaff,
                      colorScheme.secondary,
                    ),
                    _buildQuickActionItem(
                      Icons.inventory_2_rounded,
                      'Check Stock',
                      _checkStock,
                      colorScheme.tertiary,
                    ),
                    _buildQuickActionItem(
                      Icons.receipt_long_rounded,
                      'New Order',
                      _createOrder,
                      colorScheme.primary,
                    ),
                    _buildQuickActionItem(
                      Icons.analytics_rounded,
                      'Reports',
                      _viewReports,
                      colorScheme.secondary,
                    ),
                    _buildQuickActionItem(
                      Icons.qr_code_scanner_rounded,
                      'Scan QR',
                      _scanQR,
                      colorScheme.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
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
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case ActivityType.order:
        return Colors.green;
      case ActivityType.inventory:
        return Colors.orange;
      case ActivityType.personnel:
        return colorScheme.primary;
      case ActivityType.system:
        return Colors.purple;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.order:
        return Icons.shopping_cart_rounded;
      case ActivityType.inventory:
        return Icons.inventory_2_rounded;
      case ActivityType.personnel:
        return Icons.people_rounded;
      case ActivityType.system:
        return Icons.settings_rounded;
    }
  }

  // Action methods
  void _addNewBusiness() {
    Navigator.pop(context);
    // Implement add new business
  }

  void _manageAllTeams() {
    // Implement manage all teams
  }

  void _viewReports() {
    Navigator.pop(context);
    // Implement view reports
  }

  void _openSettings() {
    // Implement open settings
  }

  void _addNewStaff() {
    Navigator.pop(context);
    // Implement add new staff
  }

  void _checkStock() {
    Navigator.pop(context);
    // Implement check stock
  }

  void _createOrder() {
    Navigator.pop(context);
    // Implement create order
  }

  void _scanQR() {
    Navigator.pop(context);
    // Implement scan QR
  }
}
