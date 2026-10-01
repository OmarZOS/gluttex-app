// lib/screens/components/form/pricing_state.dart

import 'package:app_constants/app_constants.dart';
import 'package:flutter/foundation.dart';

/// Single source of truth for the pricing section.
///
/// The card is a pure view: it reads these values and emits raw user
/// input. All derivation lives here so the card never has to know how
/// base / tax / margin / final relate to each other.
///
/// Two modes:
///   - [PricingMode.byProfit]     → `profitMargin` is the input,
///                                   `finalPrice` is derived.
///   - [PricingMode.byFinalPrice] → `finalPrice` is the input,
///                                   `profitMargin` is derived.
///
/// `basePrice` and `taxPercentage` are inputs in both modes; changing
/// either re-derives the dependent value for the current mode.
class PricingState extends ChangeNotifier {
  double _basePrice = 0.0;
  double _taxPercentage = 19.0;
  double _profitMargin = 20.0;
  double _finalPrice = 0.0;
  PricingMode _mode = PricingMode.byProfit;

  // ==================== Getters ====================

  double get basePrice => _basePrice;
  double get taxPercentage => _taxPercentage;
  double get profitMargin => _profitMargin;
  double get finalPrice => _finalPrice;
  PricingMode get mode => _mode;

  /// Price after tax but before margin. Intermediate value the
  /// breakdown UI shows; computed on the fly, never stored.
  double get priceAfterTax => _basePrice * (1 + _taxPercentage / 100);

  // ==================== Setters (inputs) ====================

  set basePrice(double value) {
    if (value == _basePrice) return;
    _basePrice = value;
    _recompute();
    notifyListeners();
  }

  set taxPercentage(double value) {
    if (value == _taxPercentage) return;
    _taxPercentage = value;
    _recompute();
    notifyListeners();
  }

  /// User typed into the profit-margin field. Only meaningful in
  /// [PricingMode.byProfit]; in the other mode the margin is derived
  /// and this setter is a no-op so a stray callback can't desync state.
  set profitMargin(double value) {
    if (_mode != PricingMode.byProfit) return;
    if (value == _profitMargin) return;
    _profitMargin = value;
    _deriveFinalFromMargin();
    notifyListeners();
  }

  /// User typed into the final-price field. Only meaningful in
  /// [PricingMode.byFinalPrice]; in the other mode the final price is
  /// derived and this setter is a no-op.
  set finalPrice(double value) {
    if (_mode != PricingMode.byFinalPrice) return;
    if (value == _finalPrice) return;
    _finalPrice = value;
    _deriveMarginFromFinal();
    notifyListeners();
  }

  set mode(PricingMode value) {
    if (value == _mode) return;
    _mode = value;
    _recompute();
    notifyListeners();
  }

  // ==================== Whole-state update ====================

  /// Seed from an existing product without triggering per-field
  /// derivations mid-flight. Useful when the form is (re)initialised.
  void load({
    required double basePrice,
    double taxPercentage = 19.0,
    double? profitMargin,
    double? finalPrice,
    PricingMode mode = PricingMode.byProfit,
  }) {
    _basePrice = basePrice;
    _taxPercentage = taxPercentage;
    _mode = mode;

    if (mode == PricingMode.byProfit) {
      _profitMargin = profitMargin ?? 20.0;
      _deriveFinalFromMargin();
    } else {
      _finalPrice = finalPrice ?? 0.0;
      _deriveMarginFromFinal();
    }

    notifyListeners();
  }

  // ==================== Reset ====================

  void reset() {
    _basePrice = 0.0;
    _taxPercentage = 19.0;
    _profitMargin = 20.0;
    _finalPrice = 0.0;
    _mode = PricingMode.byProfit;
    notifyListeners();
  }

  // ==================== Derivation ====================

  void _recompute() {
    if (_mode == PricingMode.byProfit) {
      _deriveFinalFromMargin();
    } else {
      _deriveMarginFromFinal();
    }
  }

  void _deriveFinalFromMargin() {
    _finalPrice = priceAfterTax * (1 + _profitMargin / 100);
  }

  void _deriveMarginFromFinal() {
    final after = priceAfterTax;
    _profitMargin = after > 0 ? ((_finalPrice - after) / after) * 100 : 0.0;
  }
}
