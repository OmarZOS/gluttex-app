class PriceCalculator {
  static double calculateWithTax(double basePrice, double taxPercentage) {
    return basePrice * (1 + taxPercentage / 100);
  }

  static double calculateWithProfit(double priceAfterTax, double profitMargin) {
    return priceAfterTax * (1 + profitMargin / 100);
  }

  static double calculateProfitPercentage(
      double costPrice, double sellingPrice) {
    if (costPrice <= 0) return 0.0;
    return ((sellingPrice - costPrice) / costPrice) * 100;
  }

  static double calculateProfitAmount(double costPrice, double sellingPrice) {
    return sellingPrice - costPrice;
  }

  static bool isPriceWithinRange(
      double price1, double price2, double tolerancePercentage) {
    if (price1 == 0 || price2 == 0) return false;
    final difference = (price1 - price2).abs();
    final percentageDiff = (difference / price1) * 100;
    return percentageDiff <= tolerancePercentage;
  }

  static double getPriceDifference(double price1, double price2) {
    return price1 - price2;
  }

  static String getPriceDifferenceText(double price1, double price2) {
    final difference = getPriceDifference(price1, price2);
    if (difference > 0) {
      return 'Higher by DZD${difference.toStringAsFixed(2)}';
    } else if (difference < 0) {
      return 'Lower by DZD${(-difference).toStringAsFixed(2)}';
    } else {
      return 'Same price';
    }
  }
}
