import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';

class PrivilegeDialog extends StatefulWidget {
  final AppUser user;
  final String supplierName;
  final Function(List<String>) onPrivilegesUpdated;

  const PrivilegeDialog({
    Key? key,
    required this.user,
    required this.supplierName,
    required this.onPrivilegesUpdated,
  }) : super(key: key);

  @override
  State<PrivilegeDialog> createState() => _PrivilegeDialogState();
}

class _PrivilegeDialogState extends State<PrivilegeDialog> {
  final List<PrivilegeItem> _availablePrivileges = [
    PrivilegeItem(
      id: 'inventory_view',
      title: 'View Inventory',
      description: 'Can view current inventory levels and stock',
      category: 'Inventory Management',
      icon: Icons.inventory_2,
    ),
    PrivilegeItem(
      id: 'inventory_manage',
      title: 'Manage Inventory',
      description: 'Can update stock levels and manage products',
      category: 'Inventory Management',
      icon: Icons.inventory,
    ),
    PrivilegeItem(
      id: 'orders_view',
      title: 'View Orders',
      description: 'Can view customer and supplier orders',
      category: 'Order Management',
      icon: Icons.shopping_cart,
    ),
    PrivilegeItem(
      id: 'orders_manage',
      title: 'Manage Orders',
      description: 'Can create, edit, and process orders',
      category: 'Order Management',
      icon: Icons.receipt_long,
    ),
    PrivilegeItem(
      id: 'personnel_view',
      title: 'View Team',
      description: 'Can view other team members',
      category: 'Personnel Management',
      icon: Icons.people,
    ),
    PrivilegeItem(
      id: 'personnel_manage',
      title: 'Manage Team',
      description: 'Can add/remove team members and set permissions',
      category: 'Personnel Management',
      icon: Icons.manage_accounts,
    ),
    PrivilegeItem(
      id: 'reports_view',
      title: 'View Reports',
      description: 'Can access sales and performance reports',
      category: 'Analytics',
      icon: Icons.analytics,
    ),
    PrivilegeItem(
      id: 'settings_manage',
      title: 'Manage Settings',
      description: 'Can modify supplier settings and preferences',
      category: 'System',
      icon: Icons.settings,
    ),
  ];

  final Map<String, bool> _selectedPrivileges = {};

  @override
  void initState() {
    super.initState();
    // Initialize with user's current privileges
    _initializePrivileges();
  }

  void _initializePrivileges() {
    // Mock initialization - in real app, load from user data
    if (widget.user.isAdmin) {
      // Admins get all privileges
      for (var privilege in _availablePrivileges) {
        _selectedPrivileges[privilege.id] = true;
      }
    } else {
      // Default privileges for non-admins
      _selectedPrivileges['inventory_view'] = true;
      _selectedPrivileges['orders_view'] = true;
      _selectedPrivileges['personnel_view'] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            // User Info
            _buildUserInfo(),
            // Privileges List
            Expanded(
              child: _buildPrivilegesList(),
            ),
            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Manage Permissions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: widget.user.app_user_image_url != null
                  ? DecorationImage(
                      image: NetworkImage(widget.user.app_user_image_url!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: widget.user.app_user_image_url == null
                  ? Colors.blue[100]
                  : null,
            ),
            child: widget.user.app_user_image_url == null
                ? Icon(Icons.person, color: Colors.blue[600], size: 24)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.user.personFirstName} ${widget.user.personLastName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.app_user_name ?? 'No username',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.supplierName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegesList() {
    final categories = _getCategories();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: categories.length,
        itemBuilder: (context, categoryIndex) {
          final category = categories[categoryIndex];
          final categoryPrivileges = _availablePrivileges
              .where((privilege) => privilege.category == category)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Padding(
                padding: EdgeInsets.only(
                    bottom: 16, top: categoryIndex > 0 ? 24 : 0),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
              // Privileges in this category
              ...categoryPrivileges
                  .map((privilege) => _buildPrivilegeItem(privilege)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrivilegeItem(PrivilegeItem privilege) {
    final isSelected = _selectedPrivileges[privilege.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            privilege.icon,
            color: isSelected ? Colors.blue[600] : Colors.grey[600],
          ),
        ),
        title: Text(
          privilege.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.blue[800] : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          privilege.description,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.blue[600] : Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: isSelected,
          onChanged: widget.user.isAdmin && privilege.id == 'full_access'
              ? null // Don't allow changing full access for admins
              : (value) {
                  setState(() {
                    _selectedPrivileges[privilege.id] = value;
                  });
                },
          activeColor: Colors.blue[600],
        ),
        onTap: widget.user.isAdmin && privilege.id == 'full_access'
            ? null
            : () {
                setState(() {
                  _selectedPrivileges[privilege.id] = !isSelected;
                });
              },
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _savePrivileges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Permissions',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _savePrivileges() {
    final selectedPrivilegeIds = _selectedPrivileges.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    widget.onPrivilegesUpdated(selectedPrivilegeIds);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permissions updated for ${widget.user.personFirstName}'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  List<String> _getCategories() {
    return _availablePrivileges.map((p) => p.category).toSet().toList();
  }
}

class PrivilegeItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;

  PrivilegeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
  });
}
