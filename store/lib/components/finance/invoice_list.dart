import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/finance/Customer.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:event/finance_change_notifier.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:store/components/finance/document/document_details_sheet.dart';
import 'package:store/components/finance/document/new_document_sheet.dart';
import 'package:store/components/finance/document/payment_recording_sheet.dart';
import 'package:ui/components/finance/financial_ui_manager.dart';
import 'package:ui/components/finance/payment_list_screen.dart';
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
            // floatingActionButton: _buildFloatingActionButton(context, notifier),
          );
        },
      ),
    );
  }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    localizations?.total ?? 'Total',
                    FinancialUIManager.formatCurrency(totalAmount, context),
                    FinancialUIManager.infoColor,
                    context,
                  ),
                  _buildSummaryItem(
                    localizations?.paid ?? 'Paid',
                    FinancialUIManager.formatCurrency(paidAmount, context),
                    FinancialUIManager.paidColor,
                    context,
                  ),
                  _buildSummaryItem(
                    localizations?.overdue ?? 'Overdue',
                    FinancialUIManager.formatCurrency(overdueAmount, context),
                    FinancialUIManager.unpaidColor,
                    context,
                  ),
                  _buildSummaryItem(
                    localizations?.count ?? 'Count',
                    '${notifier.filteredDocuments.length}',
                    FinancialUIManager.pendingColor,
                    context,
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

  Widget _buildSummaryItem(
      String label, String value, Color color, BuildContext context) {
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

  Widget _buildFilterSection(
      BuildContext context, FinanceChangeNotifier notifier) {
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              localizations?.all ?? 'All',
              notifier.filter.documentType == null &&
                  notifier.filter.status == null,
              () => notifier.setFilter(FinanceDocumentFilter()),
              context,
            ),
            _buildFilterChip(
              localizations?.invoices ?? 'Invoices',
              notifier.filter.documentType == 'invoice',
              () => notifier.setFilter(
                notifier.filter.copyWith(
                  documentType: notifier.filter.documentType == 'invoice'
                      ? null
                      : 'invoice',
                ),
              ),
              context,
            ),
            _buildFilterChip(
              localizations?.deposits ?? 'Deposits',
              notifier.filter.documentType == 'deposit',
              () => notifier.setFilter(
                notifier.filter.copyWith(
                  documentType: notifier.filter.documentType == 'deposit'
                      ? null
                      : 'deposit',
                ),
              ),
              context,
            ),
            _buildFilterChip(
              localizations?.unpaid ?? 'Unpaid',
              notifier.filter.status == 'unpaid',
              () => notifier.setFilter(
                notifier.filter.copyWith(
                  status: notifier.filter.status == 'unpaid' ? null : 'unpaid',
                ),
              ),
              context,
            ),
            _buildFilterChip(
              localizations?.overdue ?? 'Overdue',
              notifier.filter.status == 'overdue',
              () => notifier.setFilter(
                notifier.filter.copyWith(
                  status:
                      notifier.filter.status == 'overdue' ? null : 'overdue',
                ),
              ),
              context,
            ),
            if (widget.currentUserId != null)
              _buildFilterChip(
                localizations?.myDocuments ?? 'My Documents',
                notifier.filter.clientId == widget.currentUserId,
                () => notifier.setFilter(
                  notifier.filter.copyWith(
                    clientId: notifier.filter.clientId == widget.currentUserId
                        ? null
                        : widget.currentUserId,
                  ),
                ),
                context,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool selected, VoidCallback onTap, BuildContext context) {
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
      onRefresh: () => notifier.fetchDocuments(reset: true),
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
          return _buildDocumentCard(context, document, notifier);
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
      onRefresh: () => notifier.fetchDocuments(reset: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  isFiltered
                      ? localizations?.noMatchingDocuments ??
                          'No matching documents'
                      : hasSearchQuery
                          ? localizations?.noResultsFound ?? 'No results found'
                          : localizations?.noDocumentsYet ?? 'No documents yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  isFiltered
                      ? localizations?.tryAdjustingFilters ??
                          'Try adjusting your filters to see more results'
                      : hasSearchQuery
                          ? '${localizations?.noDocumentsMatch ?? 'No documents match'} "${notifier.currentSearchQuery}"'
                          : localizations?.startCreatingFirstDocument ??
                              'Start by creating your first financial document',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              if (isFiltered)
                FilledButton.icon(
                  onPressed: () => notifier.clearFilter(),
                  icon: const Icon(Icons.filter_alt_off),
                  label: Text(localizations?.clearFilters ?? 'Clear Filters'),
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
                  label: Text(localizations?.clearSearch ?? 'Clear Search'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                )
              else if (widget.onCreateDocument != null)
                FilledButton.icon(
                  onPressed: widget.onCreateDocument,
                  icon: const Icon(Icons.add),
                  label: Text(localizations?.createFirstDocument ??
                      'Create First Document'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
              const SizedBox(height: 16),
              if (!isFiltered && !hasSearchQuery)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    localizations?.documentsWillAppearHere ??
                        'Documents will appear here once they are created',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                          localizations?.tip ?? '💡 Tip',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations?.youHaveTotalDocuments(
                                  notifier.documents.length) ??
                              '',
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
    final localizations = AppLocalizations.of(context);
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
                                _buildCustomerRow(context, document, notifier),
                                const SizedBox(height: 4),
                                _buildDocumentTypeRow(document, theme),
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
                const SizedBox(height: 12),
                if (document.dueDate != null)
                  _buildDueDateIndicator(document, theme, localizations),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          localizations?.balance ?? 'Balance',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FinancialUIManager.formatCurrency(
                              document.remainingAmount, context),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: document.remainingAmount > 0
                                ? FinancialUIManager.unpaidColor
                                : FinancialUIManager.paidColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FinancialUIManager.buildPaymentProgress(
                  context: context,
                  amount: document.documentAmount,
                  paid: document.totalPaid,
                  deposited: document.totalDeposited,
                ),
                const SizedBox(height: 16),
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
                        const SizedBox(width: 12),
                        if (document.supplierId > 0)
                          FutureBuilder<Supplier?>(
                            future: context
                                .read<SupplierChangeNotifier>()
                                .getSupplierById(context
                                    .read<ProductNotifier>()
                                    .currentProviderId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.business,
                                      size: 14,
                                      color: theme.colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      snapshot!.data!.displayName,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.tertiary,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
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
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadDocument(context, document),
                        icon: Icon(
                          Icons.download,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          localizations?.download ?? 'Download',
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
                    if (document.isPaid == false)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentFormScreen(
                                  sourceDocument: document,
                                ),
                              ),
                            ),
                          },
                          icon: Icon(
                            Icons.payment,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                          label: Text(
                            localizations?.payNow ?? 'Pay Now',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
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

  void _downloadDocument(BuildContext context, FinancialDocument document) {
    // Simple download
    context.read<FinanceChangeNotifier>().downloadDocumentWithProgress(
          document: document,
          context: context,
        );

    // OR with format selection:
    // context.read<FinanceChangeNotifier>().downloadWithFormatSelection(
    //   document,
    //   context,
    // );
  }

  Widget _buildCustomerRow(BuildContext context, FinancialDocument document,
      FinanceChangeNotifier notifier) {
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                localizations?.loading ?? 'Loading...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 6),
              Text(
                '${localizations?.customer ?? 'Customer'} ${document.customerId}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          );
        }

        final info = snapshot.data;
        final customerName = info?.displayName ??
            '${localizations?.unknown ?? 'Unknown'} ${localizations?.customer?.toLowerCase() ?? 'customer'}';

        final customerIcon = _getCustomerTypeIcon(document.customerType);

        return Row(
          children: [
            Icon(
              customerIcon,
              size: 16,
              color: _getCustomerTypeColor(document.customerType, theme),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                customerName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentTypeRow(FinancialDocument document, ThemeData theme) {
    final documentTypeName =
        FinancialUIManager.getDocumentTypeDisplay(document.documentType);
    final sourceTypeIcon = _getSourceTypeIcon(document.sourceType);
    final sourceTypeColor = _getSourceTypeColor(document.sourceType, theme);

    return Row(
      children: [
        Text(
          documentTypeName,
          style: theme.textTheme.bodyMedium?.copyWith(
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

  Widget _buildDueDateIndicator(FinancialDocument document, ThemeData theme,
      AppLocalizations? localizations) {
    if (document.dueDate == null) return const SizedBox.shrink();

    final dueDate = document.dueDate!;
    final now = DateTime.now();
    final isPastDue = dueDate.isBefore(now);
    final daysUntilDue = dueDate.difference(now).inDays;

    final paymentStatus = document.paymentStatus?.toLowerCase() ?? '';
    final isPaid = paymentStatus == 'paid' ||
        paymentStatus.contains('fully_paid') ||
        paymentStatus.contains('covers_full') ||
        paymentStatus.contains('fully_covered');

    if (isPaid) {
      return const SizedBox.shrink();
    }

    final isCanceled = paymentStatus.contains('cancel');
    if (isCanceled) {
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

    final hasPartialPayment =
        paymentStatus.contains('partial') || paymentStatus.contains('deposit');
    if (hasPartialPayment && isPastDue) {
      color = Colors.orange.shade700;
      label =
          '${localizations?.partial ?? 'Partial'} - ${localizations?.overdue?.toLowerCase() ?? 'overdue'}';
    } else if (hasPartialPayment && !isPastDue) {
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

  IconData _getCustomerTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return Icons.person;
      case 'person':
        return Icons.person_outline;
      case 'business':
      case 'company':
        return Icons.business;
      case 'organization':
        return Icons.groups;
      default:
        return Icons.person;
    }
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

  Color _getCustomerTypeColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'user':
        return Colors.blue;
      case 'person':
        return Colors.green;
      default:
        return theme.colorScheme.surfaceVariant;
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

  Widget _buildLoadMoreIndicator(
      FinanceChangeNotifier notifier, BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

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
          child: Text(localizations?.loadMore ?? 'Load More'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          localizations?.noMoreDocuments ?? 'No more documents',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
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

  void _createNewDocument(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NewDocumentSheet(
        onCreate: (type) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentFormScreen()),
          );
        },
      ),
    );
  }
}
