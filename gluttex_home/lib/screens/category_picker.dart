import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gluttex_core/app/AppUser.dart';

class CategoryPicker extends StatefulWidget {
  final ValueChanged<int> onCategoryChanged;
  final List<AppUserCategory> categories;
  final int category_id;

  const CategoryPicker({
    Key? key,
    required this.onCategoryChanged,
    required this.categories,
    required this.category_id,
  }) : super(key: key);

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    _selectedCategoryIndex = widget.categories.indexWhere(
        (category) => category.id_app_user_type == widget.category_id);
    widget.onCategoryChanged(
      widget.categories[_selectedCategoryIndex].id_app_user_type,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          // tileColor: Colors.blue[50],
          title: Text(
            widget.categories[_selectedCategoryIndex].app_user_type_desc,
          ),
          onTap: () {
            _showPicker(context);
          },
          // trailing: getAppUsercategoryIcon(
          //   widget.categories[_selectedCategoryIndex].recipe_provider_type_id,
          // ),
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
              // //log('${widget.categories[index].recipe_provider_type_id}');

              widget.onCategoryChanged(
                widget.categories[index].id_app_user_type,
              );
            },
            children: widget.categories.map((AppUserCategory category) {
              return Center(child: Text(category.app_user_type_desc));
            }).toList(),
          ),
        );
      },
    );
  }
}
