import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Recipe.dart';

class CategoryPicker extends StatefulWidget {
  final ValueChanged<int> onCategoryChanged;
  final List<String> categories;
  final int category_id;

  const CategoryPicker({
    super.key,
    required this.onCategoryChanged,
    required this.categories,
    required this.category_id,
  });

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    _selectedCategoryIndex = widget.category_id;
    widget.onCategoryChanged(
      widget.category_id,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          // tileColor: Colors.blue[50],
          title: Text(AppLocalizations.of(context)!
              .recipeCategoryTextList
              .split(",")[_selectedCategoryIndex]),
          onTap: () {
            _showPicker(context);
          },
          trailing: SvgPicture.asset(
            'assets/icons/${_selectedCategoryIndex + 1}.svg',
            color: Theme.of(context).colorScheme.primary,
            width: 40,
            height: 40,
            package: "gluttex_chef",
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
              // //log('${widget.categories[index].recipe_provider_type_id}');

              widget.onCategoryChanged(
                index,
              );
            },
            children: widget.categories.map((String category) {
              return Center(child: Text(category));
            }).toList(),
          ),
        );
      },
    );
  }
}
