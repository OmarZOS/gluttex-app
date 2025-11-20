import 'package:flutter/foundation.dart';
import 'package:gluttex_core/app/AppUser.dart';

class PersonnelProvider with ChangeNotifier {
  List<AppUser> _suppliers = [];
  List<AppUser> _filteredSuppliers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<AppUser> get suppliers => _filteredSuppliers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  PersonnelProvider() {
    // loadMockSuppliers();
  }

  // Mock data for suppliers
  Future<void> loadMockSuppliers() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _suppliers = [
      AppUser(
        id_app_user: 101,
        app_user_name: 'supplier.foodmart',
        app_user_type_id: 4, // Supplier type
        app_user_type_desc: 'Supplier',
        idPerson: 1001,
        personFirstName: 'Food',
        personLastName: 'Mart',
        personDetailsId: 2001,
        personBirthDate: '1980-05-15',
        personGender: 'Male',
        personNationality: 'Local',
        idBloodType: 1,
        bloodTypeDesc: 'O+',
        idLocation: 1,
        locationLatitude: 40.7128,
        locationLongitude: -74.0060,
        locationName: 'Main Store',
        locationAddressId: 1,
        addressStreet: '123 Supplier St',
        addressCity: 'New York',
        addressPostalCode: '10001',
        addressCountry: 'USA',
        app_user_image_url:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=150&h=150&fit=crop&crop=face',

        app_user_person_id: null,
        app_user_password: '',
        app_user_preferences: '',
      ),
      AppUser(
        id_app_user: 102,
        app_user_name: 'fresh.produce.co',
        app_user_type_id: 4,
        app_user_type_desc: 'Supplier',
        idPerson: 1002,
        personFirstName: 'Fresh',
        personLastName: 'Produce',
        personDetailsId: 2002,
        personBirthDate: '1975-08-22',
        personGender: 'Female',
        personNationality: 'Local',
        idBloodType: 2,
        bloodTypeDesc: 'A+',
        idLocation: 2,
        locationLatitude: 34.0522,
        locationLongitude: -118.2437,
        locationName: 'LA Warehouse',
        locationAddressId: 2,
        addressStreet: '456 Market Ave',
        addressCity: 'Los Angeles',
        addressPostalCode: '90001',
        addressCountry: 'USA',
        app_user_image_url:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        app_user_person_id: null,
        app_user_password: '',
        app_user_preferences: '',
      ),
      AppUser(
        id_app_user: 103,
        app_user_name: 'meat.suppliers',
        app_user_type_id: 4,
        app_user_type_desc: 'Supplier',
        idPerson: 1003,
        personFirstName: 'Prime',
        personLastName: 'Meats',
        personDetailsId: 2003,
        personBirthDate: '1982-12-10',
        personGender: 'Male',
        personNationality: 'Local',
        idBloodType: 3,
        bloodTypeDesc: 'B+',
        idLocation: 3,
        locationLatitude: 41.8781,
        locationLongitude: -87.6298,
        locationName: 'Chicago Depot',
        locationAddressId: 3,
        addressStreet: '789 Butcher Rd',
        addressCity: 'Chicago',
        addressPostalCode: '60601',
        addressCountry: 'USA',
        app_user_image_url:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        app_user_person_id: null,
        app_user_password: '',
        app_user_preferences: '',
      ),
    ];

    _filteredSuppliers = _suppliers;
    _isLoading = false;
    notifyListeners();
  }

  void searchSuppliers(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSuppliers = _suppliers;
    } else {
      _filteredSuppliers = _suppliers.where((supplier) {
        final fullName =
            '${supplier.personFirstName} ${supplier.personLastName}'
                .toLowerCase();
        final userName = supplier.app_user_name?.toLowerCase() ?? '';
        final location = supplier.locationName?.toLowerCase() ?? '';
        return fullName.contains(query.toLowerCase()) ||
            userName.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredSuppliers = _suppliers;
    notifyListeners();
  }

  Future<void> addSupplier(AppUser supplier) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    _suppliers.insert(0, supplier);
    _filteredSuppliers = _suppliers;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSupplierPrivileges(
      AppUser supplier, List<String> privileges) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, you would update the supplier's privileges via API
    final index =
        _suppliers.indexWhere((s) => s.id_app_user == supplier.id_app_user);
    if (index != -1) {
      // Update logic here - you might need to extend AppUser model for privileges
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeSupplier(AppUser supplier) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _suppliers.removeWhere((s) => s.id_app_user == supplier.id_app_user);
    _filteredSuppliers = _suppliers;

    _isLoading = false;
    notifyListeners();
  }
}
