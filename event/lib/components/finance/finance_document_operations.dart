import 'package:gluttex_core/business/finance/FinancialDocument.dart';

class FinanceDocumentOperations {
  final List<FinancialDocument> _allDocuments = [];
  final List<FinancialDocument> _primaryDocuments = [];
  final Map<int, List<int>> _documentGroups = {};

  List<FinancialDocument> get allDocuments => List.unmodifiable(_allDocuments);
  List<FinancialDocument> get primaryDocuments =>
      List.unmodifiable(_primaryDocuments);
  Map<int, List<int>> get documentGroups => Map.unmodifiable(_documentGroups);

  void addDocuments(List<FinancialDocument> newDocuments) {
    final existingIds =
        _allDocuments.map((d) => d.documentId).whereType<int>().toSet();

    for (final document in newDocuments) {
      if (document.documentId != null &&
          !existingIds.contains(document.documentId)) {
        _allDocuments.add(document);
      }
    }
  }

  void setPrimaryDocuments(List<FinancialDocument> documents) {
    _primaryDocuments.clear();
    _primaryDocuments.addAll(documents);
  }

  void clear() {
    _allDocuments.clear();
    _primaryDocuments.clear();
    _documentGroups.clear();
  }
}
