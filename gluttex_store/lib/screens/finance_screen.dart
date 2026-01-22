import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/services/BusinessOperationService.dart';
import 'package:gluttex_event/finance_change_notifier.dart';
// REMOVED: import 'package:gluttex_store/components/finance/finance_content.dart'; // Not used
// import 'package:gluttex_store/components/finance/finance_stats.dart';
import 'package:gluttex_store/components/finance/invoice_list.dart';
// CHANGED: Removed InvoiceList import since you're using EnhancedInvoiceList
import 'package:gluttex_store/components/finance/pricing_config.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_event/views/finance_view_model.dart';
// ADDED: Import for EnhancedInvoiceList
// ADDED: Import for TabNavigation
import 'package:gluttex_store/components/finance/finance_navigation.dart';
// ADDED: Import for DateFilterSelector
import 'package:gluttex_store/components/finance/finance_filters.dart';

class FinanceScreen extends StatefulWidget {
  final FinanceChangeNotifier financeNotifier;
  const FinanceScreen({super.key, required this.financeNotifier});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  // REMOVED: late final PageController _pageController; // Moved to child widget
  // late final FinanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // REMOVED: _pageController = PageController();
    // _viewModel = FinanceViewModel(
    //     businessOperationService:
    //         GluttexLocator.get<BusinessOperationService>());
    // _viewModel.loadBusinessOperations();
  }

  @override
  void dispose() {
    // REMOVED: _pageController.dispose();
    // _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FinanceLayout(model: widget.financeNotifier);
  }
}

// CHANGED: Fixed class name from __FinanceLayoutState to _FinanceLayoutState
class _FinanceLayout extends StatefulWidget {
  final FinanceChangeNotifier model;
  _FinanceLayout({required this.model});

  @override
  State<_FinanceLayout> createState() => _FinanceLayoutState();
}

class _FinanceLayoutState extends State<_FinanceLayout> {
  late PageController _pageController;
  // final FinanceChangeNotifier financeNotifier;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FinanceViewModel>(context);

    // Sync PageController with ViewModel
    if (_pageController.hasClients &&
        _pageController.page?.round() != viewModel.selectedTab.index) {
      _pageController.jumpToPage(viewModel.selectedTab.index);
    }

    return SafeArea(
      child: Column(
        children: [
          const _AppBar(),
          const DateFilterSelector(), // Make sure this widget exists
          TabNavigation(
            currentTab: viewModel.selectedTab.index,
            onTabSelected: (index) {
              final tab = FinanceTab.values[index];
              viewModel.selectTab(tab);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                final tab = FinanceTab.values[index];
                if (viewModel.selectedTab != tab) {
                  viewModel.selectTab(tab);
                }
              },
              children: [
                // Invoices Tab
                _InvoiceListView(),
                // Analytics Tab - Make sure AnalyticsView exists
                // FinanceStats(),
                // Pricing Tab - Make sure PricingConfigScreen exists
                _PricingConfigView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Invoice List View (wrapped in Consumer)
class _InvoiceListView extends StatelessWidget {
  const _InvoiceListView();

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(
      builder: (context, viewModel, child) {
        return EnhancedInvoiceList();
      },
    );
  }
}

// Pricing Config View (wrapped in Consumer)
class _PricingConfigView extends StatelessWidget {
  const _PricingConfigView();

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(
      builder: (context, viewModel, child) {
        return PricingConfigScreen(
          viewModel: viewModel.pricingConfigViewModel,
          isLoading: viewModel.isLoading,
          onSave: () => viewModel.savePricingConfig(),
          onBasePriceChanged: viewModel.handleBasePriceChanged,
          onTaxPercentageChanged: viewModel.handleTaxPercentageChanged,
          onProfitMarginChanged: viewModel.handleProfitMarginChanged,
          onFinalPriceChanged: viewModel.handleFinalPriceChanged,
          onModeChanged: viewModel.handleModeChanged,
          onToggleProductSelection: viewModel.handleToggleProductSelection,
          onToggleSelectAll: viewModel.handleToggleSelectAll,
          onUpdateSelectedProducts: viewModel.handleUpdateSelectedProducts,
          onClearSelection: viewModel.handleClearSelection,
        );
      },
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          _IconBadge(
            icon: Icons.currency_exchange,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.financeAndPricing,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  localizations.manageInvoicesAndConfigurePricing,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _ExportButton(
            onPressed: () => _handleExport(context),
            colorScheme: colorScheme,
            tooltip: localizations.exportData,
          ),
        ],
      ),
    );
  }

  void _handleExport(BuildContext context) {
    final viewModel = Provider.of<FinanceViewModel>(context, listen: false);
    viewModel.exportAnalyticsData();

    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations?.exportingData ?? 'Exporting...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;

  const _IconBadge({
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: colorScheme.onPrimary, size: 22),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final String tooltip;

  const _ExportButton({
    required this.onPressed,
    required this.colorScheme,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Icons.download, color: colorScheme.primary),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primary.withOpacity(0.1),
        padding: const EdgeInsets.all(10),
      ),
    );
  }
}
