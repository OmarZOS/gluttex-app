import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_localiser/components/Algeria.dart';

class LocationFilterBottomSheet extends StatefulWidget {
  final Function applyLocationFilter;
  final dynamic selectedLocation;

  const LocationFilterBottomSheet({
    Key? key,
    required this.applyLocationFilter,
    required this.selectedLocation,
  }) : super(key: key);

  static Future<dynamic> show(
    BuildContext context,
    Function applyLocationFilter,
    dynamic selectedLocation,
  ) async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LocationFilterBottomSheet(
          applyLocationFilter: applyLocationFilter,
          selectedLocation: selectedLocation,
        );
      },
    );

    return result;
  }

  @override
  State<LocationFilterBottomSheet> createState() =>
      _LocationFilterBottomSheetState();
}

class _LocationFilterBottomSheetState extends State<LocationFilterBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredWilayas = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredWilayas = Wilayas.wilayas;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        _filteredWilayas = Wilayas.wilayas;
      } else {
        _filteredWilayas = Wilayas.wilayas.where((wilaya) {
          final name = wilaya["name"]?.toString().toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredWilayas = Wilayas.wilayas;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      "Filter by Location",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search locations...",
                    prefixIcon: const Icon(Icons.search, size: 22),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              // Results count or empty state
              if (_isSearching && _filteredWilayas.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "No locations found",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ),

              // Location list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _filteredWilayas.length,
                  itemBuilder: (context, index) {
                    final location = _filteredWilayas[index];
                    return ListTile(
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(location["name"].toString()),
                      trailing: location == widget.selectedLocation
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        widget.applyLocationFilter(location);
                        Navigator.pop(context, location);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FilterButton extends StatelessWidget {
  final Function onPressed;
  final bool isFilterActive;
  final Color? activeColor;
  final Color? inactiveColor;

  const FilterButton({
    Key? key,
    required this.onPressed,
    required this.isFilterActive,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = this.activeColor ?? theme.colorScheme.primary;
    final inactiveColor =
        this.inactiveColor ?? theme.colorScheme.primary.withOpacity(0.7);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isFilterActive
            ? activeColor.withOpacity(0.2)
            : activeColor.withOpacity(0.1),
      ),
      child: IconButton(
        onPressed: () => onPressed(),
        icon: Icon(
          Icons.filter_list_rounded,
          color: isFilterActive ? activeColor : inactiveColor,
          size: 24,
        ),
        tooltip: 'Filter by location',
      ),
    );
  }
}
