import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:provider/provider.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final int tabIndex;
  final int supplierId;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.tabIndex,
    required this.supplierId,
  });

  String _getSearchHint(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return localizations.searchSuppliersText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Consumer<PersonnelNotifier>(
        builder: (context, notifier, _) {
          final isLoading = notifier.isLoading;

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: _getSearchHint(context),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                controller.clear();
                                notifier.clearSearch(supplierId: supplierId);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
