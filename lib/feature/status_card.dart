import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.glowColor,
    this.height = 100,
    this.icon,
    this.trailing,
    super.key,
  });

  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? glowColor;
  final double height;
  final Widget? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Card.filled(
        color: Colors.transparent, // Transparent to show container color/glow
        margin: EdgeInsets.zero,
        elevation: 0, // Remove card elevation to avoid conflict with glow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 12),
              ],
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                    ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}