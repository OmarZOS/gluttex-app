import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';

enum PricingMode { byProfit, byFinalPrice }

class PricingConfigViewModel extends ChangeNotifier {
  double _basePrice = 0.0;
  double _taxPercentage = 19.0;
  double _profitMargin = 20.0;
  double _finalPrice = 0.0;
  PricingMode _mode = PricingMode.byProfit;
  List<Product> _selectedProducts = [];
  List<Product> _products = [];

  // Getters
  double get basePrice => _basePrice;
  double get taxPercentage => _taxPercentage;
  double get profitMargin => _profitMargin;
  double get finalPrice => _finalPrice;
  PricingMode get mode => _mode;
  List<Product> get selectedProducts => _selectedProducts;
  List<Product> get products => _products;

  // Setters with calculations
  set basePrice(double value) {
    _basePrice = value;
    _calculate();
    notifyListeners();
  }

  set taxPercentage(double value) {
    _taxPercentage = value;
    _calculate();
    notifyListeners();
  }

  set profitMargin(double value) {
    _profitMargin = value;
    if (_mode == PricingMode.byProfit) {
      _calculate();
    }
    notifyListeners();
  }

  set finalPrice(double value) {
    _finalPrice = value;
    if (_mode == PricingMode.byFinalPrice) {
      _calculate();
    }
    notifyListeners();
  }

  set mode(PricingMode value) {
    _mode = value;
    _calculate();
    notifyListeners();
  }

  set products(List<Product> value) {
    _products = value;
    notifyListeners();
  }

  // Methods
  void toggleProductSelection(Product product) {
    if (_selectedProducts.contains(product)) {
      _selectedProducts.remove(product);
    } else {
      _selectedProducts.add(product);
    }
    notifyListeners();
  }

  void toggleSelectAll() {
    if (_selectedProducts.length == _products.length) {
      _selectedProducts.clear();
    } else {
      _selectedProducts = List.from(_products);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedProducts.clear();
    notifyListeners();
  }

  // Private calculation methods
  void _calculate() {
    if (_mode == PricingMode.byProfit) {
      _calculateFinalPrice();
    } else {
      _calculateProfitMargin();
    }
  }

  void _calculateFinalPrice() {
    final taxAmount = _basePrice * _taxPercentage / 100;
    final priceAfterTax = _basePrice + taxAmount;
    _finalPrice = priceAfterTax * (1 + _profitMargin / 100);
  }

  void _calculateProfitMargin() {
    final taxAmount = _basePrice * _taxPercentage / 100;
    final priceAfterTax = _basePrice + taxAmount;
    if (priceAfterTax > 0) {
      _profitMargin = ((_finalPrice - priceAfterTax) / priceAfterTax) * 100;
    } else {
      _profitMargin = 0.0;
    }
  }
}
