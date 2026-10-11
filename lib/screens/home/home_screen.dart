import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/active_car_card.dart';
import 'widgets/attention_needed_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToGarage;
  final VoidCallback? onNavigateToReminders;

  const HomeScreen({
    super.key,
    this.onNavigateToGarage,
    this.onNavigateToReminders,
  });

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Top Information Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              final titleInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ваш автомобіль під контролем',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Пробіг, обслуговування та важливі нагадування в одному місці.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );

              final metaControls = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showNotice(context, 'Документація та допомога'),
                    icon: const Icon(
                      Icons.help_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Допомога та документація',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '4 жовтня 2026',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleInfo),
                    const SizedBox(width: 16),
                    metaControls,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleInfo,
                  const SizedBox(height: 14),
                  metaControls,
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Two-column Content Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 860;

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Car Card (wider column)
                    Expanded(
                      flex: 6,
                      child: ActiveCarCard(
                        onUpdateMileage: () => _showNotice(context, 'Оновлення пробігу...'),
                        onAddMaintenance: () => _showNotice(context, 'Додавання запису ТО...'),
                        onOpenGarage: onNavigateToGarage,
                        onOpenReminders: onNavigateToReminders,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Attention Needed Card
                    Expanded(
                      flex: 4,
                      child: AttentionNeededCard(
                        onScheduleOilChange: () => _showNotice(context, 'Запис на заміну оливи'),
                        onScheduleDiagnostics: () => _showNotice(context, 'Запис на діагностику ходової'),
                        onViewAllReminders: onNavigateToReminders,
                      ),
                    ),
                  ],
                );
              }

              // Vertical stacked layout for small screens
              return Column(
                children: [
                  ActiveCarCard(
                    onUpdateMileage: () => _showNotice(context, 'Оновлення пробігу...'),
                    onAddMaintenance: () => _showNotice(context, 'Додавання запису ТО...'),
                    onOpenGarage: onNavigateToGarage,
                    onOpenReminders: onNavigateToReminders,
                  ),
                  const SizedBox(height: 20),
                  AttentionNeededCard(
                    onScheduleOilChange: () => _showNotice(context, 'Запис на заміну оливи'),
                    onScheduleDiagnostics: () => _showNotice(context, 'Запис на діагностику ходової'),
                    onViewAllReminders: onNavigateToReminders,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
