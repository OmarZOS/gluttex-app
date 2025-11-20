import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';

class SearchInviteDialog extends StatefulWidget {
  final Function(AppUser) onUserSelected;

  const SearchInviteDialog({
    Key? key,
    required this.onUserSelected,
  }) : super(key: key);

  @override
  State<SearchInviteDialog> createState() => _SearchInviteDialogState();
}

class _SearchInviteDialogState extends State<SearchInviteDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<AppUser> _mockUsers = [];
  final List<AppUser> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMockUsers();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadMockUsers() {
    _mockUsers.addAll([
      AppUser(
        id_app_user: 201,
        app_user_name: 'chef.michael',
        app_user_type_id: 2,
        app_user_type_desc: 'Chef',
        idPerson: 3001,
        personFirstName: 'Michael',
        personLastName: 'Thompson',
        personDetailsId: 4001,
        personBirthDate: '1985-03-20',
        personGender: 'Male',
        personNationality: 'American',
        app_user_image_url:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        app_user_person_id: 0,
        app_user_password: '',
        app_user_preferences: '',
        idBloodType: 0,
        bloodTypeDesc: '',
        idLocation: 0,
        locationLatitude: 0,
        locationLongitude: 0,
        locationName: '',
        locationAddressId: 0,
        addressStreet: '',
        addressCity: '',
        addressPostalCode: '',
        addressCountry: '',
      ),
      AppUser(
        id_app_user: 202,
        app_user_name: 'manager.sarah',
        app_user_type_id: 1,
        app_user_type_desc: 'Manager',
        idPerson: 3002,
        personFirstName: 'Sarah',
        personLastName: 'Johnson',
        personDetailsId: 4002,
        personBirthDate: '1990-07-15',
        personGender: 'Female',
        personNationality: 'Canadian',
        app_user_image_url:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        app_user_person_id: 0,
        app_user_password: '',
        app_user_preferences: '',
        idBloodType: 0,
        bloodTypeDesc: '',
        idLocation: 0,
        locationLatitude: 0,
        locationLongitude: 0,
        locationName: '',
        locationAddressId: 0,
        addressStreet: '',
        addressCity: '',
        addressPostalCode: '',
        addressCountry: '',
      ),
      AppUser(
        id_app_user: 203,
        app_user_name: 'supplier.david',
        app_user_type_id: 4,
        app_user_type_desc: 'Supplier',
        idPerson: 3003,
        personFirstName: 'David',
        personLastName: 'Chen',
        personDetailsId: 4003,
        personBirthDate: '1978-11-30',
        personGender: 'Male',
        personNationality: 'Chinese',
        app_user_image_url:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        app_user_person_id: 0,
        app_user_password: '',
        app_user_preferences: '',
        idBloodType: 0,
        bloodTypeDesc: '',
        idLocation: 0,
        locationLatitude: 0,
        locationLongitude: 0,
        locationName: '',
        locationAddressId: 0,
        addressStreet: '',
        addressCity: '',
        addressPostalCode: '',
        addressCountry: '',
      ),
    ]);
    _searchResults.addAll(_mockUsers);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        _searchResults.clear();
        _searchResults.addAll(_mockUsers);
      } else {
        _searchResults.clear();
        _searchResults.addAll(_mockUsers.where((user) {
          final fullName =
              '${user.personFirstName} ${user.personLastName}'.toLowerCase();
          final userName = user.app_user_name?.toLowerCase() ?? '';
          return fullName.contains(query) || userName.contains(query);
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            // Search Bar
            _buildSearchBar(),
            // Results
            Expanded(
              child: _buildResults(),
            ),
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
            'Search & Invite',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by name or username...',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_searchResults.isEmpty && _isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(AppUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            borderRadius: BorderRadius.circular(20),
            image: user.app_user_image_url != null
                ? DecorationImage(
                    image: NetworkImage(user.app_user_image_url!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: user.app_user_image_url == null ? Colors.blue[100] : null,
          ),
          child: user.app_user_image_url == null
              ? Icon(Icons.person, color: Colors.blue[600], size: 20)
              : null,
        ),
        title: Text(
          '${user.personFirstName} ${user.personLastName}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(user.app_user_name ?? 'No username'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getRoleColor(user.app_user_type_desc),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.app_user_type_desc ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          widget.onUserSelected(user);
        },
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red[400]!;
      case 'manager':
        return Colors.orange[400]!;
      case 'chef':
        return Colors.green[400]!;
      case 'supplier':
        return Colors.blue[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
