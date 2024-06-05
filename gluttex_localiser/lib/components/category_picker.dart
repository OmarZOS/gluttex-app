import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_localiser/components/supplier_icon.dart';

class CategoryPicker extends StatefulWidget {
  final ValueChanged<int> onCategoryChanged;
  final List<Category> categories;

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
            widget.categories[_selectedCategoryIndex].product_category_desc,
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
            children: widget.categories.map((Category category) {
              return Center(child: Text(category.product_category_desc));
            }).toList(),
          ),
        );
      },
    );
  }
}
