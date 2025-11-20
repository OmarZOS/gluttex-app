import 'package:flutter/material.dart';
import 'package:gluttex_personnel/personnel_management_screen.dart';
import 'package:gluttex_personnel/supplier_dashboard_provider.dart';
import 'package:provider/provider.dart';

class SupplierEntitiesScreen extends StatefulWidget {
  const SupplierEntitiesScreen({Key? key}) : super(key: key);

  @override
  State<SupplierEntitiesScreen> createState() => _SupplierEntitiesScreenState();
}

class _SupplierEntitiesScreenState extends State<SupplierEntitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSupplierList(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
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
                Colors.blue[700]!,
                Colors.indigo[900]!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Businesses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<SupplierDashboardProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      '${provider.totalSuppliers} locations • ${provider.totalPersonnel} team members',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverList _buildSupplierList() {
    final mockSuppliers = [
      SupplierEntity(
        id: 1,
        name: 'Downtown Restaurant',
        type: 'Restaurant',
        location: '123 Main St, City',
        revenue: 12500.00,
        personnelCount: 12,
        status: EntityStatus.active,
        imageUrl:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400&h=200&fit=crop',
      ),
      SupplierEntity(
        id: 2,
        name: 'Riverside Cafe',
        type: 'Cafe',
        location: '456 River Rd, Town',
        revenue: 8200.50,
        personnelCount: 8,
        status: EntityStatus.active,
        imageUrl:
            'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400&h=200&fit=crop',
      ),
      SupplierEntity(
        id: 3,
        name: 'Central Kitchen',
        type: 'Food Production',
        location: '789 Industrial Ave',
        revenue: 18500.75,
        personnelCount: 15,
        status: EntityStatus.active,
        imageUrl:
            'https://images.unsplash.com/photo-1583778176476-4a8b9f0c10c0?w=400&h=200&fit=crop',
      ),
      SupplierEntity(
        id: 4,
        name: 'Gourmet Bakery',
        type: 'Bakery',
        location: '321 Sweet St, District',
        revenue: 6500.25,
        personnelCount: 6,
        status: EntityStatus.maintenance,
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=200&fit=crop',
      ),
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final supplier = mockSuppliers[index];
          return _buildSupplierCard(supplier);
        },
        childCount: mockSuppliers.length,
      ),
    );
  }

  Widget _buildSupplierCard(SupplierEntity supplier) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPersonnelManagement(supplier),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Supplier Image
                _buildSupplierImage(supplier),
                const SizedBox(width: 16),
                // Supplier Info
                Expanded(
                  child: _buildSupplierInfo(supplier),
                ),
                // Actions
                _buildSupplierActions(supplier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierImage(SupplierEntity supplier) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: NetworkImage(supplier.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(supplier.status),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(supplier.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierInfo(SupplierEntity supplier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          supplier.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.category, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              supplier.type,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                supplier.location,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoChip(
              icon: Icons.people,
              value: '${supplier.personnelCount}',
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildInfoChip(
              icon: Icons.attach_money,
              value: '\$${supplier.revenue.toStringAsFixed(0)}',
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(
      {required IconData icon, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierActions(SupplierEntity supplier) {
    return Column(
      children: [
        IconButton(
          onPressed: () => _navigateToPersonnelManagement(supplier),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.people_alt, color: Colors.blue[600], size: 20),
          ),
        ),
        const SizedBox(height: 4),
        IconButton(
          onPressed: () => _showSupplierOptions(supplier),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          ),
        ),
      ],
    );
  }

  void _navigateToPersonnelManagement(SupplierEntity supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonnelManagementScreen(
          supplierName: supplier.name,
          supplierId: supplier.id,
        ),
      ),
    );
  }

  void _showSupplierOptions(SupplierEntity supplier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.blue),
                  title: const Text('View Analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    _viewAnalytics(supplier);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.green),
                  title: const Text('Edit Business'),
                  onTap: () {
                    Navigator.pop(context);
                    _editBusiness(supplier);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.orange),
                  title: const Text('Business Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    _businessSettings(supplier);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Archive Business'),
                  onTap: () {
                    Navigator.pop(context);
                    _archiveBusiness(supplier);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(EntityStatus status) {
    switch (status) {
      case EntityStatus.active:
        return Colors.green;
      case EntityStatus.maintenance:
        return Colors.orange;
      case EntityStatus.inactive:
        return Colors.red;
    }
  }

  String _getStatusText(EntityStatus status) {
    switch (status) {
      case EntityStatus.active:
        return 'Active';
      case EntityStatus.maintenance:
        return 'Maintenance';
      case EntityStatus.inactive:
        return 'Inactive';
    }
  }

  void _viewAnalytics(SupplierEntity supplier) {
    print('View analytics for ${supplier.name}');
  }

  void _editBusiness(SupplierEntity supplier) {
    print('Edit business ${supplier.name}');
  }

  void _businessSettings(SupplierEntity supplier) {
    print('Open settings for ${supplier.name}');
  }

  void _archiveBusiness(SupplierEntity supplier) {
    print('Archive business ${supplier.name}');
  }
}

class SupplierEntity {
  final int id;
  final String name;
  final String type;
  final String location;
  final double revenue;
  final int personnelCount;
  final EntityStatus status;
  final String imageUrl;

  SupplierEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.revenue,
    required this.personnelCount,
    required this.status,
    required this.imageUrl,
  });
}

enum EntityStatus {
  active,
  maintenance,
  inactive,
}
