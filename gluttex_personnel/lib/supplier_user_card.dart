import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';

class SupplierUserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onManagePrivileges;
  final VoidCallback onRemove;

  const SupplierUserCard({
    Key? key,
    required this.user,
    required this.onManagePrivileges,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with Role Badge
                _buildAvatarWithBadge(),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.personFirstName} ${user.personLastName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.app_user_name ?? 'No username',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildPrivilegeTags(),
                    ],
                  ),
                ),
                // Role Badge
                _buildRoleBadge(),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.admin_panel_settings,
                    text: 'Permissions',
                    onTap: onManagePrivileges,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.notifications,
                    text: 'Notify',
                    onTap: () {}, // Implement notification
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.delete_outline,
                  onTap: onRemove,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithBadge() {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            image: user.app_user_image_url != null
                ? DecorationImage(
                    image: NetworkImage(user.app_user_image_url!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: user.app_user_image_url == null ? Colors.blue[100] : null,
          ),
          child: user.app_user_image_url == null
              ? Icon(Icons.person, color: Colors.blue[600], size: 24)
              : null,
        ),
        if (user.isAdmin)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPrivilegeTags() {
    // Mock privileges - in real app, these would come from user data
    final privileges = user.isAdmin
        ? ['Full Access']
        : ['Inventory', 'Orders']; // Example privileges

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: privileges.map((privilege) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getPrivilegeColor(privilege),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            privilege,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoleBadge() {
    final role = user.app_user_type_desc ?? 'User';
    final color = _getRoleColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'chef':
        return Colors.green;
      case 'supplier':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getPrivilegeColor(String privilege) {
    switch (privilege.toLowerCase()) {
      case 'full access':
        return Colors.red;
      case 'inventory':
        return Colors.blue;
      case 'orders':
        return Colors.green;
      case 'personnel':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
