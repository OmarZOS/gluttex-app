import 'package:flutter/material.dart';
import 'package:store/components/delivery/DeliveryListView.dart';
import 'package:store/components/delivery/NewDeliverySheet.dart';
import 'package:provider/provider.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:gluttex_core/business/Delivery.dart';

class DeliveryTabbedView extends StatefulWidget {
  const DeliveryTabbedView({super.key});

  @override
  State<DeliveryTabbedView> createState() => _DeliveryTabbedViewState();
}

class _DeliveryTabbedViewState extends State<DeliveryTabbedView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = context.watch<DeliveryChangeNotifier>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              collapsedHeight: kToolbarHeight,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: theme.colorScheme.surfaceTint,
              elevation: innerBoxIsScrolled ? 4 : 0,
              title: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _showSearchBar
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Deliveries',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (notifier.deliveries.isNotEmpty) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${notifier.totalDeliveries} total',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                secondChild: Container(
                  height: kToolbarHeight,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSearchBar(theme),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (!_showSearchBar)
                  IconButton(
                    icon: Badge(
                      isLabelVisible: notifier.pendingCount > 0,
                      backgroundColor: theme.colorScheme.error,
                      label: Text(
                        notifier.pendingCount.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      child: Icon(
                        Icons.filter_alt_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onPressed: _toggleFilters,
                  ),
                IconButton(
                  icon: Icon(
                    _showSearchBar ? Icons.close : Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _toggleSearchBar,
                ),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Column(
                  children: [
                    if (_showFilters) _buildFilterChips(theme, notifier),
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.pending_outlined),
                          text: 'Pending (${notifier.pendingCount})',
                        ),
                        Tab(
                          icon: Icon(Icons.check_circle_outline),
                          text: 'Delivered (${notifier.deliveredCount})',
                        ),
                        Tab(
                          icon: Icon(Icons.cancel_outlined),
                          text: 'Cancelled',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator.adaptive(
          onRefresh: () => notifier.refreshDeliveries(),
          child: TabBarView(
            controller: _tabController,
            children: const [
              DeliveryListView(status: 'PENDING'),
              DeliveryListView(status: 'DELIVERED'),
              DeliveryListView(status: 'CANCELLED'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewDeliverySheet,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Delivery'),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: _toggleSearchBar,
          ),
          hintText: 'Search deliveries...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          // Will be implemented when search functionality is added
        },
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, DeliveryChangeNotifier notifier) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: Text('All (${notifier.totalDeliveries})'),
            selected: true,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text('Today'),
            selected: false,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text('This Week'),
            selected: false,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text('This Month'),
            selected: false,
            onSelected: (_) {},
          ),
        ],
      ),
    );
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
      }
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _showNewDeliverySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewDeliverySheet(),
    );
  }
}
