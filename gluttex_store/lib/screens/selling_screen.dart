import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/service_change_notifier.dart';
import 'package:gluttex_store/components/selling_point/selling_point_app_bar.dart';
import 'package:gluttex_store/components/selling_point/selling_point_cart.dart';
import 'package:gluttex_store/components/selling_point/selling_point_items.dart';
import 'package:gluttex_store/components/selling_point/selling_point_supplier.dart';

class SellingPointScreen extends StatefulWidget {
  final int userId;
  final List<int> accessibleSuppliers;
  final PersonnelNotifier personnelNotifier;
  final ServiceNotifier serviceNotifier;
  final CartChangeNotifier cartNotifier;
  final ProductNotifier productNotifier;
  final Function() onScanBarcode;
  final Function() onSearchChanged;

  const SellingPointScreen({
    super.key,
    required this.userId,
    required this.accessibleSuppliers,
    required this.personnelNotifier,
    required this.productNotifier,
    required this.serviceNotifier,
    required this.cartNotifier,
    required this.onScanBarcode,
    required this.onSearchChanged,
  });

  @override
  State<SellingPointScreen> createState() => _SellingPointScreenState();
}

class _SellingPointScreenState extends State<SellingPointScreen> {
  late final TextEditingController _searchController;
  int? _selectedSupplierId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSupplier();
    });
  }

  void _initializeSupplier() {
    final userRules = widget.personnelNotifier.getRulesForUser(widget.userId);

    for (final rule in userRules) {
      if (!rule.isActiveStatus) continue;

      final ruleCode = rule.management_rule_code ?? 0;
      final hasPrivilege = _checkPrivilege(ruleCode, 'orders_manage') ||
          _checkPrivilege(ruleCode, 'orders_view');

      if (hasPrivilege) {
        final supplierId = rule.productProvider?.id_product_provider;
        if (supplierId != null) {
          setState(() => _selectedSupplierId = supplierId);
          _loadSupplierProducts(supplierId);
          break;
        }
      }
    }
  }

  bool _checkPrivilege(int ruleCode, String privilegeId) {
    return RoleBitMapper.hasPrivilege(ruleCode, privilegeId);
  }

  void _loadSupplierProducts(int supplierId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.productNotifier.fetchProducts(providerId: supplierId);
    });
  }

  void _selectSupplier(int? supplierId) {
    if (supplierId != null) {
      setState(() => _selectedSupplierId = supplierId);
      _loadSupplierProducts(supplierId);
    }
  }

  void _updateSearchQuery(String query) {
    setState(() => _searchQuery = query);
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.productNotifier.products;

    final query = _searchQuery.toLowerCase();
    return widget.productNotifier.products.where((product) {
      final name = product.product_name?.toLowerCase() ?? '';
      final desc = product.product_description?.toLowerCase() ?? '';
      return name.contains(query) || desc.contains(query);
    }).toList();
  }

  List<ProductProvider> _getAccessibleSuppliers() {
    final userRules = widget.personnelNotifier.getRulesForUser(widget.userId);
    final suppliers = <ProductProvider>[];
    final supplierIds = <int>{};

    for (final rule in userRules) {
      if (!rule.isActiveStatus) continue;

      final ruleCode = rule.management_rule_code ?? 0;
      final hasPrivilege = _checkPrivilege(ruleCode, 'orders_manage') ||
          _checkPrivilege(ruleCode, 'orders_view');

      if (hasPrivilege) {
        final supplier = rule.productProvider;
        if (supplier != null &&
            !supplierIds.contains(supplier.id_product_provider)) {
          supplierIds.add(supplier.id_product_provider);
          suppliers.add(supplier);
        }
      }
    }

    return suppliers;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            SellingPointAppBar(onScanBarcode: widget.onScanBarcode),
            SupplierSelector(
              selectedSupplierId: _selectedSupplierId,
              accessibleSuppliers: _getAccessibleSuppliers(),
              onSupplierChanged: _selectSupplier,
            ),
            // SizedBox(
            //   height: 200,
            // ),
            SellingPointSearchBar(
              searchController: _searchController,
              onSearchChanged: _updateSearchQuery,
            ),
            Expanded(
              child: SellingItemGrid(
                // serviceNotifier: widget.serviceNotifier,
                // products: _filteredProducts,
                // isLoading: widget.productNotifier.isLoading,
                cartNotifier: widget.cartNotifier,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CartFAB(
        cartNotifier: widget.cartNotifier,
        productNotifier: widget.productNotifier,
        userId: widget.userId,
      ),
    );
  }
}
