import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/services/BusinessOperationService.dart';
import 'package:gluttex_store/components/finance/finance_content.dart';
import 'package:gluttex_store/components/finance/finance_stats.dart';
import 'package:gluttex_store/components/finance/invoice_list.dart';
import 'package:gluttex_store/components/finance/pricing_config.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_event/views/finance_view_model.dart';
import '../components/finance/finance_navigation.dart';
import '../components/finance/finance_filters.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late final PageController _pageController;
  late final FinanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _viewModel = FinanceViewModel(
        businessOperationService:
            GluttexLocator.get<BusinessOperationService>());
    _viewModel.loadBusinessOperations();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const _FinanceLayout(),
      ),
    );
  }
}

class _FinanceLayout extends StatefulWidget {
  const _FinanceLayout();

  @override
  State<_FinanceLayout> createState() => __FinanceLayoutState();
}

class __FinanceLayoutState extends State<_FinanceLayout> {
  late PageController _pageController;

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
          const DateFilterSelector(),
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
              children: const [
                // Invoices Tab
                _InvoiceListView(),
                // Analytics Tab
                _AnalyticsView(),
                // Pricing Tab
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
        return InvoiceList(
          orders: viewModel.orders,
          isLoading: viewModel.isLoadingInvoices,
          onRefresh: viewModel.refreshInvoices,
          onViewInvoiceDetails: viewModel.viewInvoiceDetails,
          onShareInvoice: viewModel.shareInvoice,
          onDownloadInvoice: viewModel.downloadInvoice,
          onCreateFirstInvoice: viewModel.createNewInvoice,
        );
      },
    );
  }
}

// Analytics View (wrapped in Consumer)
class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(
      builder: (context, viewModel, child) {
        return AnalyticsView(
          operations: viewModel.businessOperations,
          isLoading: viewModel.isLoadingAnalytics,
          onCreateInvoice: viewModel.createNewInvoice,
        );
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
          isLoading: viewModel.isLoadingPricing,
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
