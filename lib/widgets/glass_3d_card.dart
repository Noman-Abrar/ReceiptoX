import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A frosted "glass" panel with a soft border highlight and drop shadow —
/// gives a floating, layered look instead of a flat colored box.
/// Use for content cards, detail rows, dialogs.
class Glass3DCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const Glass3DCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppColors.raisedShadow(),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A vivid gradient card that appears to float above the background,
/// with a colored glow shadow. Use for primary content like receipt
/// list items, stat highlights, or call-to-action tiles.
class Floating3DCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const Floating3DCard({
    super.key,
    required this.child,
    this.gradient = AppColors.cardGradient,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final glowColor = gradient is LinearGradient
        ? (gradient as LinearGradient).colors.first
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppColors.glowShadow(glowColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: gradient,
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A pressable 3D button — raised look, slightly compresses the glow
/// when tapped (via InkWell splash) for tactile feedback.
class Button3D extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  const Button3D({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.glowShadow(AppColors.primary, opacity: 0.35),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: loading ? null : onPressed,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: AppColors.buttonGradient,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}