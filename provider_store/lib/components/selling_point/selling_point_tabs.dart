import 'package:flutter/material.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/service_change_notifier.dart';
import 'package:provider_store/components/selling_point/selling_items/item_card_with_controls.dart';
import 'package:provider_store/components/selling_point/selling_items/products/product_grid.dart';
import 'package:provider_store/components/selling_point/selling_items/services/service_grid.dart';
import 'package:provider_store/components/selling_point/selling_items/services/service_grid_screen.dart';
import 'package:provider_store/components/selling_point/selling_items/tab_selector.dart';
import 'package:provider/provider.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

class SellingItemTabs extends StatefulWidget {
  final CartChangeNotifier cartNotifier;

  const SellingItemTabs({
    required this.cartNotifier,
  });

  @override
  State<SellingItemTabs> createState() => _SellingItemTabsState();
}

class _SellingItemTabsState extends State<SellingItemTabs> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabSelector(
            selectedTab: _selectedTab,
            onTabChanged: (index) => setState(() => _selectedTab = index),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTab == 0) {
      // 产品网格 - 使用 ListView 包装
      return _buildProductGrid();
    } else {
      // 服务网格 - 使用 ListView 包装
      return _buildServiceGrid();
    }
  }

  Widget _buildProductGrid() {
    final productNotifier = context.watch<ProductNotifier>();
    final products = productNotifier.products;

    if (productNotifier.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(child: Text('No products'));
    }

    return ListView(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true, // 在 ListView 中需要 shrinkWrap
          physics: const NeverScrollableScrollPhysics(), // 禁用 GridView 自身滚动
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ItemCardWithConfiguration(
              item: products[index],
              // cartNotifier: widget.cartNotifier,
              isProduct: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    final serviceNotifier = context.watch<ServiceNotifier>();
    final services = serviceNotifier.services;

    if (serviceNotifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (services.isEmpty) {
      return const Center(child: Text('No services'));
    }

    // 直接使用 CustomScrollView，避免嵌套
    return CustomScrollView(
      slivers: [
        // 头部
        // SliverToBoxAdapter(
        //   child: ServicesHeader(),
        // ),
        // 服务网格（现在只返回 _ServicesGrid）
        SliverToBoxAdapter(
          child: ServiceGridSliver(),
        ),
      ],
    );
  }
}
