import 'package:flutter/material.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_personnel/privilege_dialog.dart';
import 'package:gluttex_personnel/qr_scanner_dialog.dart';
import 'package:gluttex_personnel/qr_scanner_service.dart';
import 'package:gluttex_personnel/search_invite_dialog.dart';
import 'package:gluttex_personnel/supplier_user_card.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_core/app/AppUser.dart';

class PersonnelManagementScreen extends StatefulWidget {
  final String supplierName;
  final int supplierId;

  const PersonnelManagementScreen({
    Key? key,
    required this.supplierName,
    required this.supplierId,
  }) : super(key: key);

  @override
  State<PersonnelManagementScreen> createState() =>
      _PersonnelManagementScreenState();
}

class _PersonnelManagementScreenState extends State<PersonnelManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<PersonnelProvider>().searchSuppliers(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with Supplier Context
          _buildHeader(),
          // Quick Stats
          _buildQuickStats(),
          // Search Bar
          _buildSearchBar(),
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60.0,
        bottom: 20.0,
        left: 24.0,
        right: 24.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[700]!,
            Colors.indigo[800]!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.supplierName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Personnel Management',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAdminBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer<PersonnelProvider>(
      builder: (context, provider, child) {
        final totalUsers = provider.suppliers.length;
        final activeAdmins =
            provider.suppliers.where((user) => user.isAdmin).length;
        final managers = provider.suppliers
            .where((user) => user.app_user_type_desc == 'Manager')
            .length;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', totalUsers, Icons.people_alt),
              _buildStatItem(
                  'Admins', activeAdmins, Icons.admin_panel_settings),
              _buildStatItem('Managers', managers, Icons.manage_accounts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search team members...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      context.read<PersonnelProvider>().clearSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<PersonnelProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.suppliers.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (provider.suppliers.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadMockSuppliers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.suppliers.length,
            itemBuilder: (context, index) {
              final user = provider.suppliers[index];
              return SupplierUserCard(
                user: user,
                onManagePrivileges: () => _showPrivilegeDialog(user),
                onRemove: () => _showRemoveDialog(user),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Team Members',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add team members to manage ${widget.supplierName}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddOptions,
            icon: const Icon(Icons.person_add),
            label: const Text('Add First Member'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAddOptions,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.person_add),
      label: const Text('Add Member'),
    );
  }

  void _showAddOptions() {
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
                Text(
                  'Add Team Member',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add users to manage ${widget.supplierName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildOptionButton(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan QR Code',
                  subtitle: 'Scan user profile QR code',
                  onTap: _showQRScanner,
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  icon: Icons.search,
                  title: 'Search & Invite',
                  subtitle: 'Search and invite existing users',
                  onTap: _showSearchInviteDialog,
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  icon: Icons.person_add_alt_1,
                  title: 'Create New User',
                  subtitle: 'Create new user profile',
                  onTap: _createNewUser,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue[600], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRScanner() {
    Navigator.pop(context);
    final qrService = QRScannerService();
    showDialog(
      context: context,
      builder: (context) => QRScannerDialog(
        qrScannerService: qrService,
        onUserScanned: (user) {
          _addTeamMember(user);
        },
      ),
    );
  }

  void _showSearchInviteDialog() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => SearchInviteDialog(
        onUserSelected: (user) {
          _inviteUser(user);
        },
      ),
    );
  }

  void _createNewUser() {
    Navigator.pop(context);
    // Navigate to create new user screen
    print('Create new user for ${widget.supplierName}');
  }

  void _addTeamMember(AppUser user) {
    final provider = context.read<PersonnelProvider>();
    provider.addSupplier(user);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Added ${user.personFirstName} ${user.personLastName} to ${widget.supplierName}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _inviteUser(AppUser user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Invitation sent to ${user.personFirstName} ${user.personLastName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showPrivilegeDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => PrivilegeDialog(
        user: user,
        supplierName: widget.supplierName,
        onPrivilegesUpdated: (privileges) {
          context
              .read<PersonnelProvider>()
              .updateSupplierPrivileges(user, privileges);
        },
      ),
    );
  }

  void _showRemoveDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Team Member'),
        content: Text(
            'Are you sure you want to remove ${user.personFirstName} ${user.personLastName} from ${widget.supplierName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PersonnelProvider>().removeSupplier(user);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Removed ${user.personFirstName} from ${widget.supplierName}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
