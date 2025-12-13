import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:locator/locator.dart';
import 'package:gluttex_core/business/services/ProvidedServiceManagementService.dart';

class ServiceNotifier extends ChangeNotifier {
  final ProvidedServiceManagementService _serviceManager =
      GluttexLocator.get<ProvidedServiceManagementService>();

  final List<ProvidedService> _services = [];
  bool _isLoading = false;
  bool _hasMore = true;

  bool _isFetchingDetails = false;
  bool get isFetchingDetails => _isFetchingDetails;

  String _searchQuery = '';
  int? _currentProviderId;
  int _page = 0;
  final int _pageSize = 20;

  Timer? _debounce;
  int _requestToken = 0;

  // GETTERS
  List<ProvidedService> get services => List.unmodifiable(_services);

  final Map<int, ProvidedService> _cachedServices = {};

  // Add a method to get cached service
  ProvidedService? getCachedService(int serviceId) {
    return _cachedServices[serviceId];
  }

  List<ProvidedService> get filteredServices {
    if (_searchQuery.isEmpty) return services;

    // Actually filter based on search query
    return services.where((service) {
      final name = service.name?.toLowerCase() ?? '';
      final description = service.description?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  int? get currentProviderId => _currentProviderId;

  // INTERNAL HELPERS
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _resetPagination() {
    _services.clear();
    _page = 0;
    _hasMore = true;
  }

  // ------------------------------------------------------------
  // 🔵 MAIN FETCH — paginated AND supports supplier switching
  // ------------------------------------------------------------
  Future<void> fetchServices({
    int serviceId = 0,
    int categoryId = 0,
    int providerId = 0,
    int userId = 0,
    String query = "",
    bool reset = false,
  }) async {
    if (_isLoading) return;

    // Handle supplier switching
    if (providerId != 0 && providerId != _currentProviderId) {
      _currentProviderId = providerId;
      reset = true;
      // Clear search when switching suppliers
      _searchQuery = '';
    }

    // If we're searching with a new query, reset
    if (query.isNotEmpty && query != _searchQuery) {
      _searchQuery = query;
      reset = true;
    }

    if (reset) {
      _resetPagination();
    }

    _setLoading(true);

    final int token = ++_requestToken;
    try {
      final offset = _page * _pageSize;

      final list = await _serviceManager.getAllProvidedServices(
        offset,
        _pageSize,
        serviceId: serviceId,
        categoryId: categoryId,
        providerId: (providerId != 0 ? providerId : _currentProviderId) ?? 0,
        userId: userId,
        query: _searchQuery.isNotEmpty ? _searchQuery : "",
      );

      if (token != _requestToken) return; // stale request

      if (reset) {
        _services.clear();
      }

      if (list != null) {
        _services.addAll(list);
      }

      if ((list?.length ?? 0) < _pageSize) {
        _hasMore = false;
      } else {
        _page++;
      }

      notifyListeners(); // Notify after updating list
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    } finally {
      if (token == _requestToken) {
        _setLoading(false);
      }
    }
  }

  Future<ProvidedService?> fetchServiceDetails(int serviceId) async {
    _isFetchingDetails = true;
    notifyListeners();
    try {
      final ProvidedService? service =
          await _serviceManager.getProvidedService(serviceId.toString());

      if (service != null) {
        // Update the service in the list if it exists
        final index = _services.indexWhere((s) => s.id == serviceId);
        if (index != -1) {
          _services[index] = service;
          notifyListeners();
        }
      }

      return service;
    } catch (e) {
      print('Error fetching service details: $e');
      return null;
    } finally {
      _isFetchingDetails = false;
      notifyListeners();
    }
  }

  // Add clear cache method if needed
  void clearCache() {
    _cachedServices.clear();
  }

  Future<ProvidedService?> getServiceById(int serviceId) async {
    // First check if we already have this service in our list
    try {
      final existingService = _services.firstWhere(
        (service) => service.id == serviceId,
      );
      return existingService;
    } catch (e) {
      // Service not found in list
    }

    // If not in list, fetch from API
    return await fetchServiceDetails(serviceId);
  }

  // ------------------------------------------------------------
  // 🔎 DEBOUNCED SEARCH (300 ms)
  // ------------------------------------------------------------
  Future<void> searchServices(String query) async {
    _searchQuery = query.trim();
    _debounce?.cancel();

    if (query.isEmpty) {
      // Clear search and reload
      _searchQuery = '';
      await fetchServices(reset: true);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await fetchServices(reset: true);
    });
  }

  // ------------------------------------------------------------
  // ⬇️ INFINITE SCROLL
  // ------------------------------------------------------------
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore || _searchQuery.isNotEmpty) return;
    await fetchServices(reset: false);
  }

  // ------------------------------------------------------------
  // 🔄 REFRESH
  // ------------------------------------------------------------
  Future<void> refresh() async {
    await fetchServices(reset: true);
  }

  // ------------------------------------------------------------
  // 🟢 ADD SERVICE
  // ------------------------------------------------------------
  Future<ProvidedService> addService(ProvidedService service) async {
    _setLoading(true);

    try {
      final created = await _serviceManager.addProvidedService(service);
      if (created != null) {
        _services.insert(0, created);
        notifyListeners();
      }
      return created!;
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // 🟡 UPDATE SERVICE
  // ------------------------------------------------------------
  Future<ProvidedService?> updateService(ProvidedService service) async {
    _setLoading(true);

    try {
      final updated = await _serviceManager.updateProvidedService(service);
      if (updated != null) {
        final index = _services.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          _services[index] = updated;
        }
        // Also update selected service if it's the same
        notifyListeners();
      }
      return updated;
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // 🔴 DELETE SERVICE
  // ------------------------------------------------------------
  Future<int?> deleteService(int id) async {
    _setLoading(true);

    try {
      final result = await _serviceManager.deleteProvidedService(id.toString());

      if (result != null) {
        _services.removeWhere((s) => s.id == id);
        // Clear selected service if it's the one being deleted
        notifyListeners();
      }

      return result;
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // CLEAR SEARCH
  // ------------------------------------------------------------
  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // CLEAR SELECTED SERVICE
  // ------------------------------------------------------------
  // void clearSelectedService() {
  //   _selectedService = null;
  // }

  // ------------------------------------------------------------
  // CLEAR ALL (for logout or cleanup)
  // ------------------------------------------------------------
  void clearAll() {
    _services.clear();
    _searchQuery = '';
    _currentProviderId = null;
    _page = 0;
    _hasMore = true;
    _debounce?.cancel();
    _debounce = null;
    notifyListeners();
  }
}
