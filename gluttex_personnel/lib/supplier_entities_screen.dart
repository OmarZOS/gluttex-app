import 'package:flutter/material.dart';
import 'package:gluttex_personnel/components/management/supplier_entities_content.dart';
import 'package:gluttex_personnel/components/management/supplier_entities_controller.dart';
import 'package:gluttex_ui/components/supplier/supplier_screen.dart';
import 'package:provider/provider.dart';

class SupplierEntitiesScreen extends StatefulWidget {
  const SupplierEntitiesScreen({Key? key}) : super(key: key);

  @override
  State<SupplierEntitiesScreen> createState() => _SupplierEntitiesScreenState();
}

class _SupplierEntitiesScreenState extends State<SupplierEntitiesScreen> {
  final SupplierEntitiesController _controller = SupplierEntitiesController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _controller.initializeData(context));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SupplierEntitiesState>(
      valueListenable: _controller.state,
      builder: (context, state, child) {
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                _controller.buildAppBar(context),
                _controller.buildSearchFilter(context),
                SupplierEntitiesContent(
                  controller: _controller,
                  state: state,
                ),
              ],
            ),
          ),
          floatingActionButton: _controller.buildFloatingActionButton(context),
        );
      },
    );
  }
}
