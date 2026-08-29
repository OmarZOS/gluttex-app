import 'package:flutter/material.dart';
import 'package:provider_store/components/delivery/DeliveryListView.dart';
import 'package:provider_store/components/delivery/NewDeliverySheet.dart';
import 'package:provider/provider.dart';
import 'package:event/delivery_change_notifier.dart';

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

class _DeliveryTabbedViewState extends State<DeliveryTabbedView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _showSearch = false;
  bool _showFilters = false;
  bool _isRefreshing = false;
  bool _initialized = false;

  late DeliveryChangeNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildAppBar(theme),
          _buildTabBar(theme),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _buildFAB(theme),
    );
  }

  // ==================== APP BAR ====================

  Widget _buildAppBar(ThemeData theme) {
    final isLoading = _isRefreshing || _notifier.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.08),
          ),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _showSearch
            ? _buildSearchBar(theme)
            : _buildTitleBar(theme, isLoading),
      ),
    );
  }

  Widget _buildTitleBar(ThemeData theme, bool isLoading) {
    return Row(
      children: [
        Icon(Icons.local_shipping_outlined, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Deliveries',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (_notifier.deliveries.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_notifier.totalDeliveries}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 4),
        _buildIconButton(
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh_rounded),
          onPressed: isLoading ? null : _refreshData,
          tooltip: 'Refresh',
        ),
        _buildIconButton(
          icon: Badge(
            isLabelVisible: _notifier.pendingCount > 0,
            backgroundColor: theme.colorScheme.error,
            label: Text(
              _notifier.pendingCount.toString(),
              style: const TextStyle(fontSize: 9),
            ),
            child: Icon(Icons.filter_alt_outlined, size: 22),
          ),
          onPressed: _toggleFilters,
          tooltip: 'Filters',
        ),
        _buildIconButton(
          icon: const Icon(Icons.search, size: 22),
          onPressed: _toggleSearch,
          tooltip: 'Search',
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Search deliveries...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: widget.onSearch,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        _buildIconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: () {
            _searchController.clear();
            widget.onSearch?.call('');
            _toggleSearch();
          },
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildIconButton(
      {required Widget icon, VoidCallback? onPressed, String? tooltip}) {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      tooltip: tooltip,
      splashRadius: 20,
    );
  }

  // ==================== TAB BAR ====================

  Widget _buildTabBar(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showFilters) _buildFilterChips(theme),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          dividerColor: Colors.transparent,
          tabs: [
            _buildTab(
                'Pending', _notifier.pendingCount, Icons.pending_outlined),
            _buildTab('Delivered', _notifier.deliveredCount,
                Icons.check_circle_outline),
            _buildTab(
                'Cancelled', _notifier.cancelledCount, Icons.cancel_outlined),
          ],
        ),
      ],
    );
  }

  Tab _buildTab(String label, int count, IconData icon) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text('$label ($count)'),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildChip('All (${_notifier.totalDeliveries})', true),
          _buildChip('Today', false),
          _buildChip('This Week', false),
          _buildChip('This Month', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) {},
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // ==================== CONTENT ====================

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        DeliveryListView(
          status: 'PENDING',
          selectedSupplierId: widget.selectedSupplierId,
        ),
        DeliveryListView(
          status: 'DELIVERED',
          selectedSupplierId: widget.selectedSupplierId,
        ),
        DeliveryListView(
          status: 'CANCELLED',
          selectedSupplierId: widget.selectedSupplierId,
        ),
      ],
    );
  }

  // ==================== FAB ====================

  Widget _buildFAB(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _showNewDeliverySheet,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: const Icon(Icons.add, size: 20),
      label: const Text('New Delivery', style: TextStyle(fontSize: 13)),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deliveries refreshed'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _toggleSearch() => setState(() => _showSearch = !_showSearch);

  void _toggleFilters() => setState(() => _showFilters = !_showFilters);

  void _showNewDeliverySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewDeliverySheet(notifier: _notifier),
    );
  }
}
