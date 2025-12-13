import 'package:flutter/material.dart';

class ServiceChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  const ServiceChip({
    super.key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  factory ServiceChip.duration(String text) {
    return ServiceChip(
      icon: Icons.access_time,
      text: text,
      backgroundColor: Colors.blue.withOpacity(0.1),
      foregroundColor: Colors.blue,
    );
  }

  factory ServiceChip.active(String text, {required ColorScheme colorScheme}) {
    return ServiceChip(
      icon: Icons.check_circle,
      text: text,
      backgroundColor: Colors.green.withOpacity(0.1),
      foregroundColor: Colors.green,
    );
  }

  factory ServiceChip.discount(String text,
      {required ColorScheme colorScheme}) {
    return ServiceChip(
      icon: Icons.local_offer,
      text: '$text off',
      backgroundColor: Colors.orange.withOpacity(0.1),
      foregroundColor: Colors.orange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
          ),
        ],
      ),
    );
  }
}
