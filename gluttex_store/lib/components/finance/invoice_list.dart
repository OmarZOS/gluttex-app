import 'package:flutter/material.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_event/finance_change_notifier.dart';
import 'package:gluttex_store/components/finance/document/document_details_sheet.dart';
// REMOVED: import 'package:gluttex_store/components/finance/document/filter_dialog.dart'; // Not used
import 'package:gluttex_store/components/finance/document/new_document_sheet.dart';
import 'package:gluttex_store/components/finance/document/payment_recording_sheet.dart';
import 'package:gluttex_ui/components/finance/financial_ui_manager.dart';
import 'package:gluttex_ui/components/finance/payment_list_screen.dart';
import 'package:gluttex_ui/screens/payment_form_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _notifier = widget.externalNotifier ?? FinanceChangeNotifier();

    // Setup scroll listener for infinite scroll
    if (widget.enablePagination) {
      _scrollController.addListener(_onScroll);
    }

    // Initial load
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
                  // Header with search
                  // if (widget.showSearch) _buildHeader(context, notifier),

                  // Summary section - FIXED: Added null check
                  if (widget.showSummary &&
                      notifier.filteredDocuments.isNotEmpty)
                    _buildSummarySection(context, notifier),

                  // Filter section
                  if (widget.showFilters)
                    _buildFilterSection(context, notifier),

                  // Main content
                  Expanded(
                    child: _buildContent(context, notifier),
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(context, notifier),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(
      BuildContext context, FinanceChangeNotifier notifier) {
    final totalAmount = notifier.totalAmount;
    final paidAmount = notifier.filteredDocuments
        .where((doc) => doc.isPaid)
        .fold(0.0, (sum, doc) => sum + doc.documentAmount);
    final overdueAmount = notifier.filteredDocuments
        .where((doc) => doc.isOverdue && !doc.isPaid)
        .fold(0.0, (sum, doc) => sum + doc.documentAmount);

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    'Total',
                    FinancialUIManager.formatCurrency(totalAmount, context),
                    FinancialUIManager.infoColor,
                  ),
                  _buildSummaryItem(
                    'Paid',
                    FinancialUIManager.formatCurrency(paidAmount, context),
                    FinancialUIManager.paidColor,
                  ),
                  _buildSummaryItem(
                    'Overdue',
                    FinancialUIManager.formatCurrency(overdueAmount, context),
                    FinancialUIManager.unpaidColor,
                  ),
                  _buildSummaryItem(
                    'Count',
                    '${notifier.filteredDocuments.length}',
                    FinancialUIManager.pendingColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (totalAmount > 0)
                LinearProgressIndicator(
                  value: paidAmount / totalAmount,
                  backgroundColor:
                      FinancialUIManager.unpaidColor.withOpacity(0.2),
                  color: FinancialUIManager.paidColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(
      BuildContext context, FinanceChangeNotifier notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'All',
              notifier.filter.documentType == null &&
                  notifier.filter.status == null,
              () => notifier.setFilter(FinanceDocumentFilter()),
            ),
            _buildFilterChip(
              'Invoices',
              notifier.filter.documentType == 'invoice',
              () => notifier.setFilter(
                notifier.filter.copyWith(
                  documentType: notifier.filter.documentType == 'invoice'
                      ? null
                      : 'invoice',
                ),
              ),
            ),
            _buildFilterChip(
              'Deposits',
              notifier.filter.documentType == 'deposit',
              () => notifier.setFilter(
                notifier.filter.copyWith(
                  documentType: notifier.filter.documentType == 'deposit'
                      ? null
                      : 'deposit',
                ),
              ),
            ),
            _buildFilterChip(
              'Unpaid',
              notifier.filter.status == 'unpaid',
              () => notifier.setFilter(
                notifier.filter.copyWith(
                  status: notifier.filter.status == 'unpaid' ? null : 'unpaid',
                ),
              ),
            ),
            _buildFilterChip(
              'Overdue',
              notifier.filter.status == 'overdue',
              () => notifier.setFilter(
                notifier.filter.copyWith(
                  status:
                      notifier.filter.status == 'overdue' ? null : 'overdue',
                ),
              ),
            ),
            if (widget.currentUserId != null)
              _buildFilterChip(
                'My Documents',
                notifier.filter.clientId == widget.currentUserId,
                () => notifier.setFilter(
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

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: selected
            ? FinancialUIManager.infoColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        selectedColor: FinancialUIManager.infoColor.withOpacity(0.2),
        checkmarkColor: FinancialUIManager.infoColor,
        labelStyle: TextStyle(
          color: selected ? FinancialUIManager.infoColor : Colors.grey,
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

  Widget _buildContent(BuildContext context, FinanceChangeNotifier notifier) {
    if (notifier.isLoading && notifier.filteredDocuments.isEmpty) {
      return FinancialUIManager.buildLoadingState(
        context: context,
        message: 'Loading financial documents...',
      );
    }

    if (notifier.filteredDocuments.isEmpty && !notifier.isLoading) {
      return _buildEmptyState(context, notifier);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.fetchDocuments(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: notifier.filteredDocuments.length +
            (notifier.hasMoreDocuments ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= notifier.filteredDocuments.length) {
            return _buildLoadMoreIndicator(notifier);
          }

          final document = notifier.filteredDocuments[index];
          return _buildDocumentCard(context, document, notifier);
        },
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, FinanceChangeNotifier notifier) {
    final theme = Theme.of(context);
    // FIXED: Added null-aware operator for localizations
    final localizations = AppLocalizations.of(context);

    // Check if it's a filtered empty state or truly empty
    // FIXED: Use the correct method name (isEmpty vs isEmpty())
    final isFiltered = !notifier.filter.isEmpty;
    final hasSearchQuery = notifier.currentSearchQuery != null &&
        notifier.currentSearchQuery!.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () => notifier.fetchDocuments(reset: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: Icon(
                  isFiltered
                      ? Icons.filter_alt_outlined
                      : Icons.receipt_long_outlined,
                  size: 72,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  isFiltered
                      ? 'No matching documents'
                      : hasSearchQuery
                          ? 'No results found'
                          : 'No documents yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  isFiltered
                      ? 'Try adjusting your filters to see more results'
                      : hasSearchQuery
                          ? 'No documents match "${notifier.currentSearchQuery}"'
                          : 'Start by creating your first financial document',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              if (isFiltered)
                FilledButton.icon(
                  onPressed: () => notifier.clearFilter(),
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Clear Filters'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                )
              else if (hasSearchQuery)
                FilledButton.icon(
                  onPressed: () {
                    notifier.clearFilter();
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Search'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                )
              else if (widget.onCreateDocument != null)
                FilledButton.icon(
                  onPressed: widget.onCreateDocument,
                  icon: const Icon(Icons.add),
                  label: const Text('Create First Document'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),

              const SizedBox(height: 16),

              // Additional help text
              if (!isFiltered && !hasSearchQuery)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Documents will appear here once they are created',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Stats or suggestions
              if (notifier.documents.isNotEmpty && isFiltered)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '💡 Tip',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have ${notifier.documents.length} total documents. '
                          'Try different filters or search terms.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, FinancialDocument document,
      FinanceChangeNotifier notifier) {
    final theme = Theme.of(context);
    // FIXED: Added null safety check for document.isPaid
    final isOverdue = document.isOverdue && (document.isPaid == false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isOverdue ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isOverdue
                ? FinancialUIManager.unpaidColor.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.1),
            width: isOverdue ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () =>
              widget.onDocumentTap?.call(document) ??
              _showDocumentDetails(context, document),
          onLongPress: () => widget.onDocumentLongPress?.call(document),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: FinancialUIManager.getDocumentColor(
                                      document.documentType, theme)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              FinancialUIManager.getDocumentIcon(
                                  document.documentType),
                              color: FinancialUIManager.getDocumentColor(
                                  document.documentType, theme),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  document.documentNumber,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                FinancialUIManager.buildCustomerInfo(
                                  context: context,
                                  customerType: document.customerType,
                                  customerId: document.customerId,
                                  personId: document.customerPersonId > 0
                                      ? document.customerPersonId
                                      : null,
                                ),
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
                ),

                const SizedBox(height: 16),

                // Amount and payment progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Balance',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FinancialUIManager.formatCurrency(
                              document.outstandingBalance, context),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: document.outstandingBalance > 0
                                ? FinancialUIManager.unpaidColor
                                : FinancialUIManager.paidColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Payment progress bar
                FinancialUIManager.buildPaymentProgress(
                  context: context,
                  amount: document.documentAmount,
                  paid: document.totalPaid,
                  deposited: document.totalDeposited,
                ),

                const SizedBox(height: 16),

                // Footer information
                Row(
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
                      ],
                    ),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              FinancialUIManager.unpaidColor.withOpacity(0.1),
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
                              '${document.daysOverdue}d overdue',
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
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadDocument(document),
                        icon: Icon(
                          Icons.download,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          'Download',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // FIXED: Added null safety check for document.isPaid
                    if (document.isPaid == false)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _recordPayment(document),
                          icon: Icon(
                            Icons.payment,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Pay Now',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: FinancialUIManager.infoColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(FinanceChangeNotifier notifier) {
    if (notifier.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (notifier.hasMoreDocuments) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => notifier.fetchDocuments(reset: false),
          child: const Text('Load More'),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No more documents',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
      BuildContext context, FinanceChangeNotifier notifier) {
    final theme = Theme.of(context);

    if (notifier.isLoading) return const SizedBox();

    return FloatingActionButton.extended(
      onPressed: widget.onCreateDocument ?? () => _createNewDocument(context),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(Icons.add),
      label: const Text('New Document'),
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

  void _downloadDocument(FinancialDocument document) {
    // Implement download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${document.documentNumber}...'),
        backgroundColor: FinancialUIManager.infoColor,
      ),
    );
  }

  void _recordPayment(FinancialDocument document) {
    // Implement payment recording logic
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentRecordingSheet(document: document),
    );
  }

  void _createNewDocument(BuildContext context) {
    // Implement document creation logic
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NewDocumentSheet(
        onCreate: (type) {
          // Handle document creation
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentFormScreen()),
          );
        },
      ),
    );
  }
}
