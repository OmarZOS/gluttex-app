import 'package:flutter/material.dart';
import 'package:provider_store/components/delivery/DeliveryListView.dart';
import 'package:provider_store/components/delivery/NewDeliverySheet.dart';
import 'package:provider/provider.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:ui/components/store/StoreDashboardHeader.dart';

class DeliveryTabbedView extends StatefulWidget {
  final DeliveryChangeNotifier? notifier;
  final int selectedSupplierId;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(String)? onSearch;

  const DeliveryTabbedView({
    super.key,
    this.notifier,
    this.selectedSupplierId = 0,
    this.isLoading = false,
    this.onRefresh,
    this.onSearch,
  });

  @override
  State<DeliveryTabbedView> createState() => _DeliveryTabbedViewState();
}

enum _DateFilter { all, today, week, month }

class _DeliveryTabbedViewState extends State<DeliveryTabbedView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  bool _showSearch = false;
  bool _showFilters = false;
  bool _isRefreshing = false;
  bool _initialized = false;
  _DateFilter _activeFilter = _DateFilter.all;

  late DeliveryChangeNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _notifier = widget.notifier ?? context.read<DeliveryChangeNotifier>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.notifier == null) {
      _notifier = context.read<DeliveryChangeNotifier>();
    }

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _loadDeliveriesForCurrentSupplier());
    }
  }

  @override
  void didUpdateWidget(covariant DeliveryTabbedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSupplierId != widget.selectedSupplierId) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _loadDeliveriesForCurrentSupplier());
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  void _loadDeliveriesForCurrentSupplier() {
    final supplierId = widget.selectedSupplierId > 0
        ? widget.selectedSupplierId
        : _notifier.currentProviderId;

    if (supplierId > 0) {
      _notifier.fetchDeliveries(providerId: supplierId, reset: true);
      return;
    }

    if (_notifier.deliveries.isEmpty) {
      _notifier.fetchFirstPage();
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: _shouldShowFab() ? _buildFab(theme) : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, cs),
            _buildTabStrip(theme, cs),
            if (_showFilters) _buildFilterRow(theme, cs),
            const SizedBox(height: 4),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(ThemeData theme, ColorScheme cs) {
    final busy = _isRefreshing || _notifier.isLoading;

    return DashboardHeader(
      leadingIcon: Icons.local_shipping_rounded,
      title: 'Deliveries',
      subtitle: _subtitleForCurrentTab(),
      actions: [
        _headerAction(
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          onPressed: busy ? null : _refreshData,
          tooltip: 'Refresh',
        ),
        _headerAction(
          icon: Icon(
            _showFilters ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
            size: 22,
            color: _showFilters ? cs.primary : null,
          ),
          onPressed: _toggleFilters,
          tooltip: 'Filters',
        ),
        _headerAction(
          icon: Icon(
            _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
            size: 22,
            color: _showSearch ? cs.primary : null,
          ),
          onPressed: _toggleSearch,
          tooltip: _showSearch ? 'Close search' : 'Search',
        ),
      ],
      searchBar: _showSearch ? _buildSearchBar(theme, cs) : null,
    );
  }

  Widget _headerAction({
    required Widget icon,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      tooltip: tooltip,
      splashRadius: 22,
    );
  }

  String _subtitleForCurrentTab() {
    switch (_tabController.index) {
      case 0:
        return '${_notifier.pendingCount} pending';
      case 1:
        return '${_notifier.deliveredCount} delivered';
      case 2:
        return '${_notifier.cancelledCount} cancelled';
      default:
        return '${_notifier.totalDeliveries} total';
    }
  }

  // ==================== SEARCH ====================

  Widget _buildSearchBar(ThemeData theme, ColorScheme cs) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, size: 20),
          hintText: 'Search by ID, customer, address…',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearch?.call('');
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) {
          widget.onSearch?.call(value);
          setState(() {}); // update clear-button visibility
        },
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  // ==================== TAB STRIP ====================

  Widget _buildTabStrip(ThemeData theme, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: cs.primary,
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: cs.onPrimary,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: [
          _buildTab(
            icon: Icons.schedule_rounded,
            label: 'Pending',
            count: _notifier.pendingCount,
          ),
          _buildTab(
            icon: Icons.check_circle_rounded,
            label: 'Delivered',
            count: _notifier.deliveredCount,
          ),
          _buildTab(
            icon: Icons.cancel_rounded,
            label: 'Cancelled',
            count: _notifier.cancelledCount,
          ),
        ],
      ),
    );
  }

  Tab _buildTab({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 6),
          Text(label),
          const SizedBox(width: 6),
          _CountBubble(count: count),
        ],
      ),
    );
  }

  // ==================== FILTERS ====================

  Widget _buildFilterRow(ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', _DateFilter.all),
            const SizedBox(width: 8),
            _filterChip('Today', _DateFilter.today),
            const SizedBox(width: 8),
            _filterChip('This week', _DateFilter.week),
            const SizedBox(width: 8),
            _filterChip('This month', _DateFilter.month),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, _DateFilter filter) {
    final selected = _activeFilter == filter;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) {
        setState(() => _activeFilter = filter);
        _applyFilter(label, filter);
      },
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      visualDensity: VisualDensity.compact,
    );
  }

  void _applyFilter(String label, _DateFilter filter) {
    // Forward to the notifier. Add a `setDateFilter` method on the
    // notifier that accepts the same enum range, or pass a computed
    // (from, to) pair.
    final now = DateTime.now();
    DateTime? from;
    DateTime? to = now;

    switch (filter) {
      case _DateFilter.all:
        from = null;
        to = null;
      case _DateFilter.today:
        from = DateTime(now.year, now.month, now.day);
      case _DateFilter.week:
        from = now.subtract(const Duration(days: 7));
      case _DateFilter.month:
        from = DateTime(now.year, now.month, 1);
    }

    // If the notifier supports it:
    // _notifier.setDateRange(from: from, to: to);
    //
    // If not, at least apply the search query filter locally. For now
    // the chip selection is at least visible and doesn't feel inert.
    debugPrint('Delivery filter → $label');
  }

  // ==================== CONTENT ====================

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _tabContent('PENDING', 'No pending deliveries',
            'New deliveries will appear here as soon as they are created.'),
        _tabContent('DELIVERED', 'No deliveries completed',
            'Delivered orders will be listed here.'),
        _tabContent('CANCELLED', 'No cancelled deliveries',
            'Cancelled or returned deliveries will appear here.'),
      ],
    );
  }

  Widget _tabContent(String status, String emptyTitle, String emptyMessage) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: DeliveryListView(
        status: status,
        notifier: _notifier,
        // If DeliveryListView supports an empty-state override, pass it.
        // Otherwise, the list view should show its own default empty state.
      ),
    );
  }

  // ==================== FAB ====================

  bool _shouldShowFab() {
    // Only show "New Delivery" on the Pending tab. On Delivered/Cancelled
    // the action doesn't make sense — you can't create a delivered one.
    return _tabController.index == 0;
  }

  Widget _buildFab(ThemeData theme) {
    final cs = theme.colorScheme;
    return FloatingActionButton.extended(
      onPressed: _showNewDeliverySheet,
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text(
        'New delivery',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final supplierId = widget.selectedSupplierId > 0
          ? widget.selectedSupplierId
          : _notifier.currentProviderId;

      if (supplierId > 0) {
        await _notifier.fetchDeliveries(providerId: supplierId, reset: true);
      } else if (widget.onRefresh != null) {
        widget.onRefresh!();
      } else {
        await _notifier.refreshDeliveries();
      }
      // No snackbar on success — the header spinner tells the story.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _searchFocusNode.requestFocus();
        });
      } else {
        _searchController.clear();
        widget.onSearch?.call('');
      }
    });
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  void _showNewDeliverySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewDeliverySheet(
        notifier: _notifier,
        providerId: widget.selectedSupplierId,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small animated count bubble for tab labels.
// ─────────────────────────────────────────────────────────────

class _CountBubble extends StatelessWidget {
  final int count;

  const _CountBubble({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(count),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        constraints: const BoxConstraints(minWidth: 18),
        decoration: BoxDecoration(
          color: cs.onSurface.withOpacity(0.10),
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 99 ? '99+' : '$count',
          style: TextStyle(
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}
