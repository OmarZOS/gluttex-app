import 'package:flutter/material.dart';

class GlutenFreeBadge extends StatelessWidget {
  final bool isGlutenFree;

  const GlutenFreeBadge({super.key, required this.isGlutenFree});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isGlutenFree
            ? _getGlutenFreeGradient()
            : _getContainsGlutenGradient(colorScheme),
        boxShadow: [
          BoxShadow(
            color: isGlutenFree
                ? const Color(0xFF10B981).withOpacity(0.5)
                : colorScheme.error.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 20,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGlutenFree ? Icons.verified : Icons.warning_rounded,
                size: 32,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isGlutenFree ? 'GLUTEN\nFREE' : 'CONTAINS\nGLUTEN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Gradient _getGlutenFreeGradient() {
    return const RadialGradient(
      colors: [
        Color(0xFF10B981), // Emerald
        Color(0xFF059669),
        Color(0xFF047857),
      ],
      center: Alignment.topLeft,
      radius: 0.8,
    );
  }

  Gradient _getContainsGlutenGradient(ColorScheme colorScheme) {
    return RadialGradient(
      colors: [
        colorScheme.error,
        colorScheme.error.withOpacity(0.8),
      ],
    );
  }
}
