import 'package:flutter/material.dart';
import 'dashboard_item.dart';

class DashboardBottomNav extends StatefulWidget {
  final int selectedIndex;
  final List<DashboardItem> items;
  final ValueChanged<int> onIndexChanged;

  const DashboardBottomNav({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onIndexChanged,
  });

  @override
  State<DashboardBottomNav> createState() => _DashboardBottomNavState();
}

class _DashboardBottomNavState extends State<DashboardBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _bubbleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant DashboardBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animationController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(widget.items.length, (i) {
          final item = widget.items[i];
          return Expanded(
            child: _NavItem(
              item: item,
              isSelected: widget.selectedIndex == item.index,
              animation: _bubbleAnimation,
              onTap: () => widget.onIndexChanged(item.index),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final DashboardItem item;
  final bool isSelected;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            AnimatedBuilder(
              animation: animation,
              builder: (_, __) {
                return Transform.translate(
                  offset: Offset(0, -4 * animation.value),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withOpacity(0.10),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: isSelected ? 40 : 32,
                height: isSelected ? 40 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? cs.primary
                      : cs.surfaceVariant.withOpacity(0.6),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  item.icon,
                  size: isSelected ? 20 : 18,
                  color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 16,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Text(
                          item.label,
                          key: const ValueKey("selected"),
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          item.label,
                          key: const ValueKey("unselected"),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
