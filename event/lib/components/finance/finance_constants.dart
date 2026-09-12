class FinanceConstants {
  static const int pageSize = 50;
  static const int maxSearchResults = 100;
  static const Duration debounceDuration = Duration(milliseconds: 300);
}

class FinanceStatuses {
  static const String paid = 'paid';
  static const String unpaid = 'unpaid';
  static const String partiallyPaid = 'partially_paid';
  static const String overdue = 'overdue';
  static const String deposited = 'deposited';
  static const String pending = 'pending';
  static const String cancelled = 'cancelled';
  static const String refunded = 'refunded';
}

class FinanceDocumentTypes {
  static const String invoice = 'invoice';
  static const String receipt = 'receipt';
  static const String deposit = 'deposit';
  static const String cart = 'cart';
  static const String pendingCart = 'pending_cart';
}
