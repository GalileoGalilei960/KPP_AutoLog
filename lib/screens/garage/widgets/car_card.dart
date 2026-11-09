import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/vehicle.dart';

class CarCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetActive;

  const CarCard({
    super.key,
    required this.vehicle,
    this.onEdit,
    this.onDelete,
    this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo & Status Row
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 125,
                  width: double.infinity,
                  color: const Color(0xFF1E293B),
                  child: vehicle.photoUrl != null && vehicle.photoUrl!.isNotEmpty
                      ? Image.asset(
                          vehicle.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 54,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 54,
                            color: Colors.white54,
                          ),
                        ),
                ),
              ),
              if (vehicle.isActive)
                const Positioned(
                  top: 10,
                  left: 10,
                  child: AppBadge.active(),
                ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textPrimary),
                    tooltip: 'Дії',
                    onSelected: (val) {
                      switch (val) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'active':
                          onSetActive?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Редагувати'),
                          ],
                        ),
                      ),
                      if (!vehicle.isActive)
                        const PopupMenuItem(
                          value: 'active',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Зробити активним'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.dangerText),
                            SizedBox(width: 8),
                            Text('Видалити', style: TextStyle(color: AppColors.dangerText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title & Fuel
          Text(
            vehicle.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${vehicle.year} рік · ${vehicle.fuelType}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Mileage & Plate number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Пробіг',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vehicle.currentMileage} км',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (vehicle.plateNumber != null && vehicle.plateNumber!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Номер',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.plateNumber!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
