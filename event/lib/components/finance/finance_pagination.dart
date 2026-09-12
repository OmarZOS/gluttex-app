import 'package:event/components/finance/finance_constants.dart';

class FinancePagination {
  int _currentPage = 0;
  bool _hasMore = true;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  void reset() {
    _currentPage = 0;
    _hasMore = true;
  }

  void update(int fetchedCount) {
    if (fetchedCount < FinanceConstants.pageSize) {
      _hasMore = false;
    } else {
      _currentPage++;
    }
  }

  void setHasMore(bool hasMore) {
    _hasMore = hasMore;
  }

  int get nextOffset => _currentPage * FinanceConstants.pageSize;
}
