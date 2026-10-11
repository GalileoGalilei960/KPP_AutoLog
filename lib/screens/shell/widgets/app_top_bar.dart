import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_badge.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final bool isDashboard;
  final VoidCallback? onAddRecord;
  final VoidCallback? onOpenMenu;

  const AppTopBar({
    super.key,
    required this.title,
    this.isDashboard = true,
    this.onAddRecord,
    this.onOpenMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          if (onOpenMenu != null) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onOpenMenu,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 12),
          const Spacer(),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDashboard) ...[
                    // Vehicle dropdown selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.directions_car_outlined, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 8),
                          Text(
                            'Volkswagen Golf · 2015',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Cloud sync pill
                    const AppBadge.cloudSync(),
                    const SizedBox(width: 12),

                    // Add Record Button
                    ElevatedButton.icon(
                      onPressed: onAddRecord,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Додати запис'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Profile top bar badge
                    const AppBadge.dataSync(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
