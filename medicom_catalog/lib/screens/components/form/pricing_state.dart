import 'package:flutter/material.dart';
import 'package:gluttex_event/views/pricing_config_view_model.dart';
import 'package:gluttex_ui/components/pricing_config_card.dart';

class PricingState with ChangeNotifier {
  double _basePrice = 0.0;
  double _taxPercentage = 10.0; // Default tax
  double _profitMargin = 30.0; // Default profit margin
  double _finalPrice = 0.0;
  PricingMode _mode = PricingMode.byProfit;

  double get basePrice => _basePrice;
  double get taxPercentage => _taxPercentage;
  double get profitMargin => _profitMargin;
  double get finalPrice => _finalPrice;
  PricingMode get mode => _mode;

  // Update from AI suggested price
  void updateFromAISuggestion(double aiPrice) {
    _basePrice = aiPrice;
    _recalculatePrices();
    notifyListeners();
  }

  void updateBasePrice(double price) {
    _basePrice = price;
    _recalculatePrices();
    notifyListeners();
  }

  void updateTaxPercentage(double percentage) {
    _taxPercentage = percentage;
    _recalculatePrices();
    notifyListeners();
  }

  void updateProfitMargin(double margin) {
    _profitMargin = margin;
    if (_mode == PricingMode.byProfit) {
      _recalculatePrices();
    }
    notifyListeners();
  }

  void updateFinalPrice(double price) {
    _finalPrice = price;
    if (_mode == PricingMode.byFinalPrice) {
      _recalculateFromFinalPrice();
    }
    notifyListeners();
  }

  void updateMode(PricingMode newMode) {
    _mode = newMode;
    _recalculatePrices();
    notifyListeners();
  }

  void _recalculatePrices() {
    final taxAmount = _basePrice * _taxPercentage / 100;
    final priceAfterTax = _basePrice + taxAmount;

    if (_mode == PricingMode.byProfit) {
      _finalPrice = priceAfterTax * (1 + _profitMargin / 100);
    }
    // If mode is byFinalPrice, finalPrice is set by user
  }

  void _recalculateFromFinalPrice() {
    final taxAmount = _basePrice * _taxPercentage / 100;
    final priceAfterTax = _basePrice + taxAmount;

    if (_mode == PricingMode.byFinalPrice && priceAfterTax > 0) {
      final profitAmount = _finalPrice - priceAfterTax;
      _profitMargin = (profitAmount / priceAfterTax) * 100;
    }
  }

  // Calculate suggested retail price based on AI price
  double calculateSuggestedRetailPrice(double aiPrice) {
    return aiPrice * (1 + _taxPercentage / 100) * (1 + _profitMargin / 100);
  }

  void reset() {
    _basePrice = 0.0;
    _taxPercentage = 10.0;
    _profitMargin = 30.0;
    _finalPrice = 0.0;
    _mode = PricingMode.byProfit;
    notifyListeners();
  }
}
