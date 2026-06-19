import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

class InventorySearchBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final bool isEnabled;

  const InventorySearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.isEnabled = true,
  });

  @override
  State<InventorySearchBar> createState() => _InventorySearchBarState();
}

class _InventorySearchBarState extends State<InventorySearchBar> {
  final TextEditingController _controller = TextEditingController();
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    _controller.addListener(_onTextChanged);
    _controller.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(InventorySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update enabled state
    if (widget.isEnabled != _isEnabled) {
      setState(() {
        _isEnabled = widget.isEnabled;
      });
    }

    // Sync controller text with widget searchQuery if they differ
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isEnabled) {
      widget.onSearchChanged(_controller.text.trim());
    }
  }

  void _clearSearch() {
    if (_isEnabled) {
      _controller.clear();
      widget.onSearchChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _isEnabled
              ? colorScheme.surface
              : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isEnabled
                ? colorScheme.outline.withOpacity(0.1)
                : colorScheme.outline.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _controller,
          enabled: _isEnabled,
          decoration: InputDecoration(
            hintText: localizations.searchTxt,
            hintStyle: TextStyle(
              color: _isEnabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isEnabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
              size: 20,
            ),
            suffixIcon: widget.searchQuery.isNotEmpty && _isEnabled
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    onPressed: _clearSearch,
                    splashRadius: 16,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            filled: false,
          ),
          style: TextStyle(
            color: _isEnabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.5),
          ),
          cursorColor: _isEnabled ? colorScheme.primary : Colors.transparent,
        ),
      ),
    );
  }
}
