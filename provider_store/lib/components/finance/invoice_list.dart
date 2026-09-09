import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/finance/Customer.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:event/finance_change_notifier.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:provider_store/components/finance/document/document_details_sheet.dart';
import 'package:provider_store/components/finance/document/new_document_sheet.dart';
import 'package:ui/components/finance/financial_ui_manager.dart';
import 'package:ui/screens/payment_form_screen.dart';
import 'package:provider/provider.dart';

class EnhancedInvoiceList extends StatefulWidget {
  final int? currentUserId;
  final FinanceChangeNotifier? externalNotifier;
  final Function(FinancialDocument)? onDocumentTap;
  final Function(FinancialDocument)? onDocumentLongPress;
  final Function()? onCreateDocument;
  final bool showSummary;
  final bool showFilters;
  final bool showSearch;
  final bool enablePagination;

  const EnhancedInvoiceList({
    super.key,
    this.currentUserId,
    this.externalNotifier,
    this.onDocumentTap,
    this.onDocumentLongPress,
    this.onCreateDocument,
    this.showSummary = true,
    this.showFilters = true,
    this.showSearch = true,
    this.enablePagination = true,
  });

  @override
  State<EnhancedInvoiceList> createState() => _EnhancedInvoiceListState();
}

class _EnhancedInvoiceListState extends State<EnhancedInvoiceList> {
  late FinanceChangeNotifier _notifier;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _notifier = widget.externalNotifier ?? FinanceChangeNotifier();

    if (widget.enablePagination) {
      _scrollController.addListener(_onScroll);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.fetchDocuments(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_notifier.hasMoreDocuments && !_notifier.isLoading) {
        _notifier.fetchDocuments(reset: false);
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await _notifier.fetchDocuments(reset: true);
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<FinanceChangeNotifier>(
        builder: (context, notifier, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, notifier),
                  if (widget.showSummary &&
                      notifier.filteredDocuments.isNotEmpty)
                    _buildSummarySection(context, notifier),
                  if (widget.showFilters)
                    _buildFilterSection(context, notifier),
                  Expanded(
                    child: _buildContent(context, notifier),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(BuildContext context, FinanceChangeNotifier notifier) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.financialDocuments ?? 'Financial Documents',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (notifier.filteredDocuments.isNotEmpty)
                  Text(
                    '${notifier.filteredDocuments.length} ${localizations?.documents ?? 'documents'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          // Reload Button
          IconButton(
            onPressed: _isRefreshing ? null : _refresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: localizations?.refresh ?? 'Refresh',
          ),
          // Search Button
          if (widget.showSearch)
            IconButton(
              onPressed: () => _showSearchDialog(context, notifier),
              icon: const Icon(Icons.search),
              tooltip: localizations?.search ?? 'Search',
            ),
          // Add Button
          if (widget.onCreateDocument != null)
            IconButton(
              onPressed: widget.onCreateDocument,
              icon: const Icon(Icons.add),
              tooltip: localizations?.addDocument ?? 'Add Document',
            ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, FinanceChangeNotifier notifier) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.searchDocuments ?? 'Search Documents'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: localizations?.searchByNumberOrCustomer ??
                'Search by number or customer',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (value) {
            // notifier.setSearchQuery(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              // notifier.setSearchQuery(_searchController.text);
              Navigator.pop(context);
            },
            child: Text(localizations?.search ?? 'Search'),
          ),
        ],
      ),
    );
  }

  // ==================== SUMMARY ====================

  Widget _buildSummarySection(
      BuildContext context, FinanceChangeNotifier notifier) {
    final localizations = AppLocalizations.of(context);
    final totalAmount = notifier.totalAmount;
    final paidAmount = notifier.filteredDocuments
        .fold(0.0, (sum, doc) => sum + doc.totalReceived);
    final overdueAmount = notifier.filteredDocuments
            .where((doc) => doc.isOverdue && !doc.isPaid)
            .fold(0.0, (sum, doc) => sum + doc.documentAmount) +
        notifier.filteredDocuments
            .where((doc) => doc.isOverdue && doc.isPartiallyPaid)
            .fold(0.0, (sum, doc) => sum + doc.remainingAmount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: localizations?.total ?? 'Total',
                    value:
                        FinancialUIManager.formatCurrency(totalAmount, context),
                    color: FinancialUIManager.infoColor,
                  ),
                  _SummaryItem(
                    label: localizations?.paid ?? 'Paid',
                    value:
                        FinancialUIManager.formatCurrency(paidAmount, context),
                    color: FinancialUIManager.paidColor,
                  ),
                  _SummaryItem(
                    label: localizations?.overdue ?? 'Overdue',
                    value: FinancialUIManager.formatCurrency(
                        overdueAmount, context),
                    color: FinancialUIManager.unpaidColor,
                  ),
                  _SummaryItem(
                    label: localizations?.count ?? 'Count',
                    value: '${notifier.filteredDocuments.length}',
                    color: FinancialUIManager.pendingColor,
                  ),
                ],
              ),
              if (totalAmount > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: paidAmount / totalAmount,
                  backgroundColor:
                      FinancialUIManager.unpaidColor.withOpacity(0.2),
                  color: FinancialUIManager.paidColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FILTERS ====================

  Widget _buildFilterSection(
      BuildContext context, FinanceChangeNotifier notifier) {
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: localizations?.all ?? 'All',
              selected: notifier.filter.documentType == null &&
                  notifier.filter.status == null,
              onTap: () => notifier.setFilter(FinanceDocumentFilter()),
            ),
            _FilterChip(
              label: localizations?.invoices ?? 'Invoices',
              selected: notifier.filter.documentType == 'invoice',
              onTap: () => notifier.setFilter(
                notifier.filter.copyWith(
                  documentType: notifier.filter.documentType == 'invoice'
                      ? null
                      : 'invoice',
                ),
              ),
            ),
            _FilterChip(
              label: localizations?.deposits ?? 'Deposits',
              selected: notifier.filter.documentType == 'deposit',
              onTap: () => notifier.setFilter(
                notifier.filter.copyWith(
                  documentType: notifier.filter.documentType == 'deposit'
                      ? null
                      : 'deposit',
                ),
              ),
            ),
            _FilterChip(
              label: localizations?.unpaid ?? 'Unpaid',
              selected: notifier.filter.status == 'unpaid',
              onTap: () => notifier.setFilter(
                notifier.filter.copyWith(
                  status: notifier.filter.status == 'unpaid' ? null : 'unpaid',
                ),
              ),
            ),
            _FilterChip(
              label: localizations?.overdue ?? 'Overdue',
              selected: notifier.filter.status == 'overdue',
              onTap: () => notifier.setFilter(
                notifier.filter.copyWith(
                  status:
                      notifier.filter.status == 'overdue' ? null : 'overdue',
                ),
              ),
            ),
            if (widget.currentUserId != null)
              _FilterChip(
                label: localizations?.myDocuments ?? 'My Documents',
                selected: notifier.filter.clientId == widget.currentUserId,
                onTap: () => notifier.setFilter(
                  notifier.filter.copyWith(
                    clientId: notifier.filter.clientId == widget.currentUserId
                        ? null
                        : widget.currentUserId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== CONTENT ====================

  Widget _buildContent(BuildContext context, FinanceChangeNotifier notifier) {
    final localizations = AppLocalizations.of(context);

    if (notifier.isLoading && notifier.filteredDocuments.isEmpty) {
      return FinancialUIManager.buildLoadingState(
        context: context,
        message: localizations?.loadingFinancialDocuments ??
            'Loading financial documents...',
      );
    }

    if (notifier.filteredDocuments.isEmpty && !notifier.isLoading) {
      return _buildEmptyState(context, notifier);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: notifier.filteredDocuments.length +
            (notifier.hasMoreDocuments ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= notifier.filteredDocuments.length) {
            return _buildLoadMoreIndicator(notifier, context);
          }
          final document = notifier.filteredDocuments[index];
          return _DocumentCard(
            document: document,
            notifier: notifier,
            onTap: () =>
                widget.onDocumentTap?.call(document) ??
                _showDocumentDetails(context, document),
            onLongPress: () => widget.onDocumentLongPress?.call(document),
            onDownload: () => _downloadDocument(context, document),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, FinanceChangeNotifier notifier) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isFiltered = !notifier.filter.isEmpty;
    final hasSearchQuery = notifier.currentSearchQuery != null &&
        notifier.currentSearchQuery!.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFiltered
                      ? Icons.filter_alt_outlined
                      : Icons.receipt_long_outlined,
                  size: 72,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  isFiltered
                      ? localizations?.noMatchingDocuments ??
                          'No matching documents'
                      : hasSearchQuery
                          ? localizations?.noResultsFound ?? 'No results found'
                          : localizations?.noDocumentsYet ?? 'No documents yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    isFiltered
                        ? localizations?.tryAdjustingFilters ??
                            'Try adjusting your filters'
                        : hasSearchQuery
                            ? '${localizations?.noDocumentsMatch ?? 'No documents match'} "${notifier.currentSearchQuery}"'
                            : localizations?.startCreatingFirstDocument ??
                                'Start by creating your first document',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                if (isFiltered)
                  FilledButton.icon(
                    onPressed: () => notifier.clearFilter(),
                    icon: const Icon(Icons.filter_alt_off),
                    label: Text(localizations?.clearFilters ?? 'Clear Filters'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(
      FinanceChangeNotifier notifier, BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (notifier.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          notifier.hasMoreDocuments
              ? (localizations?.loadMore ?? 'Load More')
              : (localizations?.noMoreDocuments ?? 'No more documents'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  void _downloadDocument(BuildContext context, FinancialDocument document) {
    context.read<FinanceChangeNotifier>().downloadDocumentWithProgress(
          document: document,
          context: context,
        );
  }

  void _showDocumentDetails(BuildContext context, FinancialDocument document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DocumentDetailsSheet(document: document),
    );
  }
}

// ==================== SUMMARY ITEM WIDGET ====================

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ==================== FILTER CHIP WIDGET ====================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: selected
            ? FinancialUIManager.infoColor.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant.withOpacity(0.1),
        selectedColor: FinancialUIManager.infoColor.withOpacity(0.2),
        checkmarkColor: FinancialUIManager.infoColor,
        labelStyle: TextStyle(
          color: selected
              ? FinancialUIManager.infoColor
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? FinancialUIManager.infoColor : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

// ==================== DOCUMENT CARD WIDGET ====================

class _DocumentCard extends StatelessWidget {
  final FinancialDocument document;
  final FinanceChangeNotifier notifier;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onDownload;

  const _DocumentCard({
    required this.document,
    required this.notifier,
    required this.onTap,
    this.onLongPress,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isOverdue = document.isOverdue && !document.isPaid;
    final isPartiallyPaid = document.isPartiallyPaid;
    final isPaid = document.isPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isOverdue ? 4 : (isPartiallyPaid ? 3 : 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isOverdue
                ? FinancialUIManager.unpaidColor.withOpacity(0.3)
                : isPartiallyPaid
                    ? Colors.orange.withOpacity(0.3)
                    : theme.colorScheme.outline.withOpacity(0.1),
            width: isOverdue ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(context),
                const SizedBox(height: 12),
                _buildDueDateIndicator(context),
                const SizedBox(height: 8),
                _buildAmountRow(context),
                const SizedBox(height: 12),
                _buildPaymentProgress(context),
                const SizedBox(height: 12),
                _buildFooterRow(context),
                const SizedBox(height: 12),
                _buildActionsRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FinancialUIManager.getDocumentColor(
                    document.documentType,
                    Theme.of(context),
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FinancialUIManager.getDocumentIcon(document.documentType),
                  color: FinancialUIManager.getDocumentColor(
                    document.documentType,
                    Theme.of(context),
                  ),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerName(context),
                    const SizedBox(height: 2),
                    _buildDocumentTypeRow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        FinancialUIManager.buildStatusBadge(
          context: context,
          status: document.paymentStatus,
        ),
      ],
    );
  }

  Widget _buildCustomerName(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return FutureBuilder<Customer?>(
      future: context.read<PersonnelNotifier>().getCustomerDisplayInfo(
            customerId: document.customerId,
            customerType: document.customerType,
            personId: document.customerPersonId > 0
                ? document.customerPersonId
                : null,
          ),
      builder: (context, snapshot) {
        final customerName = snapshot.hasData && snapshot.data != null
            ? snapshot.data!.displayName
            : '${localizations?.customer ?? 'Customer'} ${document.customerId}';

        return Text(
          customerName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _buildDocumentTypeRow(BuildContext context) {
    final theme = Theme.of(context);
    final documentTypeName =
        FinancialUIManager.getDocumentTypeDisplay(document.documentType);
    final sourceTypeIcon = _getSourceTypeIcon(document.sourceType);
    final sourceTypeColor = _getSourceTypeColor(document.sourceType, theme);

    return Row(
      children: [
        Text(
          documentTypeName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        if (sourceTypeIcon != null) ...[
          const SizedBox(width: 6),
          Icon(
            sourceTypeIcon,
            size: 14,
            color: sourceTypeColor,
          ),
        ],
      ],
    );
  }

  IconData? _getSourceTypeIcon(String sourceType) {
    switch (sourceType) {
      case 'cart_based':
        return Icons.shopping_cart;
      case 'order_based':
        return Icons.receipt;
      case 'invoice_based':
        return Icons.description;
      case 'direct_invoice':
        return Icons.request_quote;
      default:
        return null;
    }
  }

  Color _getSourceTypeColor(String sourceType, ThemeData theme) {
    switch (sourceType) {
      case 'cart_based':
        return Colors.purple;
      case 'order_based':
        return Colors.teal;
      case 'invoice_based':
        return Colors.indigo;
      case 'direct_invoice':
        return Colors.deepOrange;
      default:
        return theme.colorScheme.secondary;
    }
  }

  Widget _buildDueDateIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    if (document.dueDate == null) return const SizedBox.shrink();

    final isPaid = document.isPaid;
    if (isPaid) return const SizedBox.shrink();

    if (document.isCanceled) {
      return Row(
        children: [
          Icon(
            Icons.cancel,
            size: 14,
            color: FinancialUIManager.canceledColor,
          ),
          const SizedBox(width: 6),
          Text(
            localizations?.canceled ?? 'Canceled',
            style: theme.textTheme.bodySmall?.copyWith(
              color: FinancialUIManager.canceledColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final isPastDue = document.isOverdue;
    final daysUntilDue = document.daysUntilDue;

    Color color;
    String label;
    IconData icon = Icons.schedule;

    if (isPastDue) {
      color = FinancialUIManager.unpaidColor;
      label = localizations?.overdue ?? 'Overdue';
      icon = Icons.warning;
    } else if (daysUntilDue <= 7) {
      color = Colors.orange;
      label = localizations?.dueSoon ?? 'Due soon';
      icon = Icons.notification_important;
    } else {
      color = Colors.green;
      label = localizations?.onTrack ?? 'On track';
      icon = Icons.schedule;
    }

    if (document.isPartiallyPaid && isPastDue) {
      color = Colors.orange.shade700;
      label =
          '${localizations?.partial ?? 'Partial'} - ${localizations?.overdue?.toLowerCase() ?? 'overdue'}';
    } else if (document.isPartiallyPaid && !isPastDue) {
      color = Colors.teal;
      label = localizations?.partiallyPaid ?? 'Partially Paid';
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isPaid = document.isPaid;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Amount
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations?.amount ?? 'Amount',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              FinancialUIManager.formatCurrency(
                  document.documentAmount, context),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        // Balance / Paid
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isPaid
                  ? (localizations?.paid ?? 'Paid')
                  : (localizations?.balance ?? 'Balance'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isPaid
                  ? FinancialUIManager.formatCurrency(
                      document.totalReceived, context)
                  : FinancialUIManager.formatCurrency(
                      document.remainingAmount, context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPaid
                    ? FinancialUIManager.paidColor
                    : (document.remainingAmount > 0
                        ? FinancialUIManager.unpaidColor
                        : FinancialUIManager.paidColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentProgress(BuildContext context) {
    final totalAmount = document.documentAmount;
    final totalReceived = document.totalReceived;
    final paymentPercentage =
        totalAmount > 0 ? (totalReceived / totalAmount) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(paymentPercentage * 100).toStringAsFixed(0)}% ${_getPaymentStatusLabel()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getPaymentStatusColor(),
              ),
            ),
            Text(
              FinancialUIManager.formatCurrency(totalReceived, context),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: paymentPercentage.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            color: _getPaymentStatusColor(),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  String _getPaymentStatusLabel() {
    if (document.isPaid) return 'Paid';
    if (document.isPartiallyPaid) return 'Partial';
    if (document.isOverdue) return 'Overdue';
    return 'Unpaid';
  }

  Color _getPaymentStatusColor() {
    if (document.isPaid) return FinancialUIManager.paidColor;
    if (document.isPartiallyPaid) return Colors.orange;
    if (document.isOverdue) return FinancialUIManager.unpaidColor;
    return FinancialUIManager.pendingColor;
  }

  Widget _buildFooterRow(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isOverdue = document.isOverdue && !document.isPaid;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              FinancialUIManager.formatDate(document.issueDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            if (document.documentNumber.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.receipt,
                    size: 14,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    document.documentNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (isOverdue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: FinancialUIManager.unpaidColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  size: 12,
                  color: FinancialUIManager.unpaidColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${document.daysOverdue}d ${localizations?.overdue?.toLowerCase() ?? 'overdue'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: FinancialUIManager.unpaidColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isPaid = document.isPaid;
    final isPartiallyPaid = document.isPartiallyPaid;

    return Row(
      children: [
        // Download button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDownload,
            icon: Icon(
              Icons.download,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              localizations?.download ?? 'Download',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Pay Now button
        if (!isPaid && !document.isCanceled) ...[
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentFormScreen(
                      sourceDocument: document,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.payment,
                size: 16,
                color: theme.colorScheme.onPrimary,
              ),
              label: Text(
                isPartiallyPaid
                    ? (localizations?.payRemaining ?? 'Pay Remaining')
                    : (localizations?.payNow ?? 'Pay Now'),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                backgroundColor: isPartiallyPaid
                    ? Colors.orange
                    : FinancialUIManager.infoColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
