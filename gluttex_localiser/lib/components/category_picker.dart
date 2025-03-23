import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_localiser/components/supplier_icon.dart';

class CategoryPicker extends StatefulWidget {
  final ValueChanged<int> onCategoryChanged;
  final List<SupplierCategory> categories;

  const CategoryPicker({
    Key? key,
    required this.onCategoryChanged,
    required this.categories,
  }) : super(key: key);

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          // tileColor: Colors.blue[50],
          title: Text(
            AppLocalizations.of(context)!
                .providerCategoryTextList
                .split(",")[_selectedCategoryIndex],
          ),
          onTap: () {
            _showPicker(context);
          },
          trailing: getProviderTypeIcon(
            widget.categories[_selectedCategoryIndex].product_provider_type_id,
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              if (mounted) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              }
              //log('${widget.categories[index].product_provider_type_id}');

              widget.onCategoryChanged(
                widget.categories[index].product_provider_type_id,
              );
            },
            children: widget.categories.map((SupplierCategory category) {
              return Center(
                  child: Text(
                AppLocalizations.of(context)!
                    .providerCategoryTextList
                    .split(",")[category.product_provider_type_id - 1],
              ));
            }).toList(),
          ),
        );
      },
    );
  }
}
