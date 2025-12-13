import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_store/components/operations/business_operations_filters.dart';
import 'package:gluttex_store/components/operations/business_operations_header.dart';
import 'package:gluttex_store/components/operations/business_operations_list.dart';
import 'package:gluttex_store/components/operations/business_operations_stats.dart';
import 'package:gluttex_store/screens/business_operation_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_event/views/finance_view_model.dart';

class BusinessOperationsScreen extends StatelessWidget {
  const BusinessOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanceViewModel>();
    final operations = viewModel.businessOperations;

    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
      return RefreshIndicator(
        onRefresh: () => viewModel.refreshBusinessOperations(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Section
            const SliverToBoxAdapter(child: BusinessOperationsHeader()),

            // Filters Section
            const SliverToBoxAdapter(child: BusinessOperationsFilters()),

            // Stats Summary
            if (operations.isNotEmpty)
              SliverToBoxAdapter(
                child: BusinessOperationsStats(operations: operations),
              ),

            // Operations List
            if (operations.isNotEmpty)
              BusinessOperationsList(
                operations: viewModel.businessOperations,
                isLoadingMore: viewModel.isLoadingMore,
                hasMore: viewModel.hasMore,
                onLoadMore: () => viewModel.loadMoreBusinessOperations(),
                onTapOperation: (operation) {
                  // Navigate to loader screen first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OperationDetailsLoaderScreen(
                        operation: operation,
                        financeViewModel: viewModel,
                      ),
                    ),
                  );
                },
              ),

            // Empty State or Loading
            if (operations.isEmpty && !viewModel.isLoading)
              SliverFillRemaining(
                child: _EmptyState(),
              )
            else if (operations.isEmpty && viewModel.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );
    });
  }
}

// Loader screen that fetches details before showing operation details
class OperationDetailsLoaderScreen extends StatefulWidget {
  final BusinessOperation operation;
  final FinanceViewModel financeViewModel;

  const OperationDetailsLoaderScreen({
    super.key,
    required this.operation,
    required this.financeViewModel,
  });

  @override
  State<OperationDetailsLoaderScreen> createState() =>
      _OperationDetailsLoaderScreenState();
}

class _OperationDetailsLoaderScreenState
    extends State<OperationDetailsLoaderScreen> {
  late Future<void> _loadingFuture;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadOperationDetails();
  }

  Future<void> _loadOperationDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Based on operation type, fetch appropriate details
      if (widget.operation.cartId != null) {
        await _loadCartDetails();
      } else if (widget.operation.orderId != null) {
        await _loadOrderDetails();
      }

      // Also ensure the operation is available in the filtered list
      final operationExists = widget.financeViewModel.businessOperations
          .any((op) => _areOperationsEqual(op, widget.operation));

      if (!operationExists) {
        // Refresh operations if this one isn't in the current list
        await widget.financeViewModel.refreshBusinessOperations();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCartDetails() async {
    final cartId = widget.operation.cartId!;

    // Check if cart exists in cart notifier
    final cartNotifier = Provider.of<CartChangeNotifier>(
      context,
      listen: false,
    );

    // If cart not in cache, fetch it
    final cartExists =
        cartNotifier.apiCarts.any((cart) => cart.cartId == cartId);
    if (!cartExists) {
      await cartNotifier.fetchCartDetails(cartId);
    }
  }

  Future<void> _loadOrderDetails() async {
    final orderId = widget.operation.orderId!;

    // Check if order exists in cart notifier
    final cartNotifier = Provider.of<CartChangeNotifier>(
      context,
      listen: false,
    );

    // If order not in cache, fetch it
    final orderExists =
        cartNotifier.orders.any((order) => order.idOrder == orderId);
    if (!orderExists) {
      await cartNotifier.fetchOrderDetails(orderId: orderId);
    }
  }

  bool _areOperationsEqual(BusinessOperation a, BusinessOperation b) {
    return a.cartId == b.cartId &&
        a.orderId == b.orderId &&
        a.supplierId == b.supplierId &&
        a.totalAmount == b.totalAmount;
  }

  void _handleRetry() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadingFuture = _loadOperationDetails();
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        // Show loading state
        if (_isLoading) {
          return _buildLoadingScreen(theme, colorScheme);
        }

        // Show error state
        if (_errorMessage != null) {
          return _buildErrorScreen(theme, colorScheme);
        }

        // Show operation details screen
        return OperationDetailsScreen(
          operation: widget.operation,
          // onRefresh: () async {
          //   await _loadOperationDetails();
          // },
        );
      },
    );
  }

  Widget _buildLoadingScreen(ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loader
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Operation Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.operation.cartId != null
                  ? 'Fetching cart items...'
                  : 'Fetching order details...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Operation preview
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.operation.cartId != null
                              ? Icons.shopping_cart
                              : Icons.receipt_long,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.operation.cartId != null
                              ? 'Cart #${widget.operation.cartId}'
                              : 'Order #${widget.operation.orderId}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.operation.totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusChip(
                          widget.operation.paymentStatus, theme, colorScheme),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                          widget.operation.invoiceStatus, theme, colorScheme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: const Text('Error Loading Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Details',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: _handleRetry,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
      String status, ThemeData theme, ColorScheme colorScheme) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'unpaid':
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'overdue':
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      default:
        backgroundColor = colorScheme.surfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.noBusinessOperations,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                localizations.generateOperationsToSeeData,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
