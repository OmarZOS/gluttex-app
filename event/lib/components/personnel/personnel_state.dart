import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/app/Person.dart';

class PersonnelState {
  // Main data
  final List<AppUser> personnel = [];
  List<AppUser> searchResults = [];
  List<Person> personSearchResults = [];

  // State
  bool isLoading = false;
  String searchQuery = '';
  String? error;
  int currentPage = 0;
  bool hasMore = true;
  bool isRebuildingState = false;

  // Statistics
  int get totalCount {
    // This would need to be calculated based on actual data
    return personnel.length;
  }

  void reset() {
    personnel.clear();
    searchResults.clear();
    personSearchResults.clear();
    isLoading = false;
    searchQuery = '';
    error = null;
    currentPage = 0;
    hasMore = true;
  }

  void resetPagination() {
    currentPage = 0;
    hasMore = true;
    personnel.clear();
  }

  void setLoading(bool loading) {
    isLoading = loading;
  }

  void setError(String? errorMessage) {
    error = errorMessage;
  }

  void setSearchQuery(String query) {
    searchQuery = query;
  }
}
