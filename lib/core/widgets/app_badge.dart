import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppBadgeVariant { info, neutral, success, warning, danger }

class AppBadge extends StatelessWidget {
  final String text;
  final Widget? icon;
  final AppBadgeVariant variant;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const AppBadge({
    super.key,
    required this.text,
    this.icon,
    this.variant = AppBadgeVariant.info,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 12,
  });

  const AppBadge.cloudSync({
    super.key,
    this.text = 'Cloud · синхронізовано',
    this.variant = AppBadgeVariant.info,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.fontSize = 12,
  }) : icon = const Icon(Icons.cloud_outlined, size: 14, color: AppColors.primary);

  const AppBadge.dataSync({
    super.key,
    this.text = 'Дані синхронізовано',
    this.variant = AppBadgeVariant.info,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.fontSize = 12,
  }) : icon = null;

  const AppBadge.neutral({
    super.key,
    required this.text,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 12,
  }) : variant = AppBadgeVariant.neutral;

  const AppBadge.active({
    super.key,
    this.text = 'Активний',
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 12,
  })  : variant = AppBadgeVariant.info,
        icon = const Icon(Icons.check, size: 13, color: AppColors.primary);

  const AppBadge.mileage({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 12,
  })  : variant = AppBadgeVariant.info,
        icon = const Icon(Icons.speed, size: 14, color: AppColors.primary);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (variant) {
      case AppBadgeVariant.info:
        bg = AppColors.infoBg;
        fg = AppColors.primary;
        break;
      case AppBadgeVariant.neutral:
        bg = AppColors.chipBackground;
        fg = AppColors.chipText;
        break;
      case AppBadgeVariant.success:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case AppBadgeVariant.warning:
        bg = AppColors.warningBg;
        fg = AppColors.warningText;
        break;
      case AppBadgeVariant.danger:
        bg = AppColors.dangerBg;
        fg = AppColors.dangerText;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
