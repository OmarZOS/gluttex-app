import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:ui/components/finance/financial_ui_manager.dart';

class BusinessOperationsStats extends StatelessWidget {
  final List<BusinessOperation> operations;

  const BusinessOperationsStats({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final stats = _calculateStats();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Quick Stats
          _QuickStats(stats: stats, localizations: localizations),
          const SizedBox(height: 16),

          // Distribution Charts
          _DistributionCharts(
              operations: operations, localizations: localizations),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    final totalAmount = operations.fold(0.0, (sum, op) => sum + op.totalAmount);
    final totalPaid = operations.fold(0.0, (sum, op) => sum + op.totalPaid);
    final balanceDue = operations.fold(0.0, (sum, op) => sum + op.balanceDue);
    final paidPercentage =
        totalAmount > 0 ? (totalPaid / totalAmount * 100) : 0;

    return {
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'balanceDue': balanceDue,
      'paidPercentage': paidPercentage,
    };
  }
}

class _QuickStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  final AppLocalizations localizations;

  const _QuickStats({
    required this.stats,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final paidPercentage = stats['paidPercentage'] as double;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.08),
            colorScheme.surfaceVariant.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 饼图进度指示器
          _CircularProgress(
            value: paidPercentage / 100,
            label: '${paidPercentage.toStringAsFixed(1)}%',
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),

          // 统计数据
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow(
                  label: localizations.totalAmount,
                  value: _formatCurrency(stats['totalAmount'], context),
                  color: colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  label: localizations.totalPaid,
                  value: _formatCurrency(stats['totalPaid'], context),
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  label: localizations.outstanding,
                  value: _formatCurrency(stats['balanceDue'], context),
                  color: stats['balanceDue'] > 0 ? Colors.orange : Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double value;
  final String label;
  final Color color;

  const _CircularProgress({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DistributionCharts extends StatelessWidget {
  final List<BusinessOperation> operations;
  final AppLocalizations localizations;

  const _DistributionCharts({
    required this.operations,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sourceDistribution = _calculateSourceDistribution();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.sourceDistribution,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 饼图和图例
          _PieChartWithLegend(
            distribution: sourceDistribution,
            localizations: localizations,
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateSourceDistribution() {
    final distribution = <String, double>{};
    for (final operation in operations) {
      final source = _getSourceDisplayName(operation);
      distribution.update(
        source,
        (value) => value + operation.totalAmount,
        ifAbsent: () => operation.totalAmount,
      );
    }
    return distribution;
  }

  String _getSourceDisplayName(BusinessOperation operation) {
    switch (operation.sourceTable.toLowerCase()) {
      case 'cart_based':
        return 'cart';
      case 'order_based':
        return 'order';
      case 'invoice_based':
        return 'invoice';
      case 'receipt_based':
        return 'receipt';
      default:
        return operation.sourceTable;
    }
  }
}

class _PieChartWithLegend extends StatelessWidget {
  final Map<String, double> distribution;
  final AppLocalizations localizations;

  const _PieChartWithLegend({
    required this.distribution,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = distribution.values.fold(0.0, (sum, value) => sum + value);

    if (distribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart,
                size: 48,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.noDataAvailable,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 准备饼图数据
    final pieSections = <PieChartSectionData>[];
    final legendItems = <_LegendItemData>[];

    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.amber,
      Colors.teal,
      Colors.purple,
    ];

    int colorIndex = 0;
    distribution.forEach((key, value) {
      final percentage = total > 0 ? (value / total * 100) : 0;
      final color = colors[colorIndex % colors.length];

      // 饼图区块
      pieSections.add(
        PieChartSectionData(
          value: value,
          color: color,
          radius: 60,
          title: '${percentage.toStringAsFixed(1)}%',
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.6,
          borderSide: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
      );

      // 图例项
      legendItems.add(_LegendItemData(
        label: _getLocalizedSourceName(key, localizations),
        value: value,
        percentage: percentage.toDouble(),
        color: color,
      ));

      colorIndex++;
    });

    return Row(
      children: [
        // 饼图
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                centerSpaceRadius: 40,
                startDegreeOffset: -90, // 从顶部开始
                sectionsSpace: 2, // 区块间距
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // 可添加点击交互
                  },
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ),
        const SizedBox(width: 20),

        // 图例
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...legendItems.map((item) => _LegendItem(
                    data: item,
                    showValue: true,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  String _getLocalizedSourceName(String source, AppLocalizations loc) {
    switch (source.toLowerCase()) {
      case 'cart':
        return loc.cart;
      case 'order':
        return loc.order;
      case 'invoice':
        return loc.invoice;
      case 'receipt':
        return loc.receipt;
      default:
        return source;
    }
  }
}

class _LegendItemData {
  final String label;
  final double value;
  final double percentage;
  final Color color;

  _LegendItemData({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

class _LegendItem extends StatelessWidget {
  final _LegendItemData data;
  final bool showValue;

  const _LegendItem({
    required this.data,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 颜色标记
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),

          // 标签
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showValue)
                  Text(
                    '${_formatCurrency(data.value, context)} • ${data.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 添加需要的本地化键到ARB文件
extension LocalizationKeys on AppLocalizations {
  String get sourceDistribution => 'Source Distribution';
  String get noDataAvailable => 'No data available';
  String get invoice => 'Invoice';
  String get receipt => 'Receipt';
  String get outstanding => 'Outstanding';
}

String _formatCurrency(double amount, BuildContext context) {
  return FinancialUIManager.formatCurrency(amount, context);
}
