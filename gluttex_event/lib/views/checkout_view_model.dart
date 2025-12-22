import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gluttex_core/app/AppUser.dart';

class CheckoutParameter {
  final String key;
  final String value;

  CheckoutParameter({required this.key, required this.value});

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

  factory CheckoutParameter.fromMap(Map<String, dynamic> map) {
    return CheckoutParameter(
      key: map['key'] ?? '',
      value: map['value'] ?? '',
    );
  }
}

class CheckoutViewModel extends ChangeNotifier {
  AppUser? _selectedCustomer;
  Person? _selectedPerson;
  String _documentType = 'receipt';
  String _paymentType = 'payment';
  String _paymentMethod = 'cash';
  String _deliveryType = 'pickup';
  String _notes = '';
  List<CheckoutParameter> _parameters = [];
  bool _isProcessing = false;
  String? _cardDetails;
  String? _bankDetails;
  String? _mobileProvider;
  String _cardType = 'visa';
  final List<CheckoutParameter> _savedParameters = [];
  bool _isLoadingParameters = false;

  static const String _prefsKey = 'checkout_parameters';

  AppUser? get selectedCustomer => _selectedCustomer;
  Person? get selectedPerson => _selectedPerson;
  String get documentType => _documentType;
  String get paymentType => _paymentType;
  String get paymentMethod => _paymentMethod;
  String get deliveryType => _deliveryType;
  String get notes => _notes;
  List<CheckoutParameter> get parameters => _parameters;
  List<CheckoutParameter> get savedParameters => _savedParameters;
  bool get isProcessing => _isProcessing;
  String? get cardDetails => _cardDetails;
  String? get bankDetails => _bankDetails;
  String? get mobileProvider => _mobileProvider;
  String get cardType => _cardType;
  bool get isLoadingParameters => _isLoadingParameters;

  Future<Person?> createNewCustomer(Person person) async {
    try {
      _isProcessing = true;
      notifyListeners();

      // Here you would call your API to save the person to the database
      // For example:
      // final createdPerson = await _personService.createPerson(person);

      // For now, let's assume we have a method to create a person
      // Since this is just the UI implementation, you'll need to implement
      // the actual API call based on your backend

      print('Creating new customer: ${person.fullName}');

      // Convert Person to AppUser if needed for your existing system
      // final appUser = _convertPersonToAppUser(person);

      // Set as selected customer
      _selectedPerson = person;

      notifyListeners();

      // Return the created person (or null if you want to return AppUser)
      return person;
    } catch (e) {
      print('Error creating customer: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  CheckoutViewModel() {
    _loadSavedParameters();
  }

  Future<void> _loadSavedParameters() async {
    _isLoadingParameters = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final parametersJson = prefs.getStringList(_prefsKey) ?? [];

      _savedParameters.clear();
      for (final jsonString in parametersJson) {
        try {
          final map = json.decode(jsonString) as Map<String, dynamic>;
          _savedParameters.add(CheckoutParameter.fromMap(map));
        } catch (e) {
          print('Error parsing parameter: $e');
        }
      }
    } catch (e) {
      print('Error loading parameters: $e');
    } finally {
      _isLoadingParameters = false;
      notifyListeners();
    }
  }

  Future<void> saveParameter(CheckoutParameter parameter) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Add to saved parameters if not already present
      if (!_savedParameters.any((p) => p.key == parameter.key)) {
        _savedParameters.add(parameter);

        // Save to SharedPreferences
        final parametersJson =
            _savedParameters.map((p) => json.encode(p.toMap())).toList();

        await prefs.setStringList(_prefsKey, parametersJson);

        notifyListeners();
      }
    } catch (e) {
      print('Error saving parameter: $e');
      rethrow;
    }
  }

  Future<void> updateParameter(int index, CheckoutParameter parameter) async {
    try {
      if (index >= 0 && index < _savedParameters.length) {
        _savedParameters[index] = parameter;

        final prefs = await SharedPreferences.getInstance();
        final parametersJson =
            _savedParameters.map((p) => json.encode(p.toMap())).toList();

        await prefs.setStringList(_prefsKey, parametersJson);

        notifyListeners();
      }
    } catch (e) {
      print('Error updating parameter: $e');
      rethrow;
    }
  }

  Future<void> deleteParameter(int index) async {
    try {
      if (index >= 0 && index < _savedParameters.length) {
        _savedParameters.removeAt(index);

        final prefs = await SharedPreferences.getInstance();
        final parametersJson =
            _savedParameters.map((p) => json.encode(p.toMap())).toList();

        await prefs.setStringList(_prefsKey, parametersJson);

        notifyListeners();
      }
    } catch (e) {
      print('Error deleting parameter: $e');
      rethrow;
    }
  }

  void useSavedParameter(CheckoutParameter parameter) {
    if (!_parameters.any((p) => p.key == parameter.key)) {
      _parameters
          .add(CheckoutParameter(key: parameter.key, value: parameter.value));
      notifyListeners();
    }
  }

  void setSelectedCustomer(AppUser? customer, Person? person) {
    _selectedCustomer = customer;
    _selectedPerson = person;
    notifyListeners();
  }

  void setDocumentType(String type) {
    _documentType = type;
    notifyListeners();
  }

  void setPaymentType(String type) {
    _paymentType = type;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setDeliveryType(String type) {
    _deliveryType = type;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  void setParameters(List<CheckoutParameter> parameters) {
    _parameters = parameters;
    notifyListeners();
  }

  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void setCardDetails(String? details) {
    _cardDetails = details;
    notifyListeners();
  }

  void setBankDetails(String? details) {
    _bankDetails = details;
    notifyListeners();
  }

  void setMobileProvider(String? provider) {
    _mobileProvider = provider;
    notifyListeners();
  }

  void setCardType(String type) {
    _cardType = type;
    notifyListeners();
  }

  void addParameter(String key, String value) {
    _parameters.add(CheckoutParameter(key: key, value: value));
    notifyListeners();
  }

  void removeParameter(int index) {
    if (index >= 0 && index < _parameters.length) {
      _parameters.removeAt(index);
      notifyListeners();
    }
  }

  void clearAll() {
    _selectedCustomer = null;
    _documentType = 'receipt';
    _paymentType = 'payment';
    _paymentMethod = 'cash';
    _deliveryType = 'pickup';
    _notes = '';
    _parameters.clear();
    _cardDetails = null;
    _bankDetails = null;
    _mobileProvider = null;
    _cardType = 'visa';
    notifyListeners();
  }

  void clearCurrentParameters() {
    _parameters.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void resetAfterCheckout() {
    _selectedCustomer = null;
    _selectedPerson = null;
    _notes = '';
    _parameters.clear();
    _cardDetails = null;
    _bankDetails = null;
    _mobileProvider = null;
    notifyListeners();
  }
}
