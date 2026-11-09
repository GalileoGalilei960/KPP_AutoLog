import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/maintenance_record.dart';

class RecordListItem extends StatelessWidget {
  final MaintenanceRecord record;
  final VoidCallback? onTap;

  const RecordListItem({
    super.key,
    required this.record,
    this.onTap,
  });

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'ТО':
        return Icons.build_circle_outlined;
      case 'Ремонт':
        return Icons.handyman_outlined;
      case 'Паливо':
        return Icons.local_gas_station_outlined;
      case 'Деталі':
        return Icons.category_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'ТО':
        return AppColors.primary;
      case 'Ремонт':
        return const Color(0xFFD97706);
      case 'Паливо':
        return const Color(0xFF059669);
      case 'Деталі':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(record.category);
    final iconData = _getCategoryIcon(record.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        borderRadius: 14,
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: catColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Main Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatDate(record.serviceDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ${record.mileageAtService} км',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          record.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          record.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (record.serviceStationName != null &&
                      record.serviceStationName!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      record.serviceStationName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Cost & Receipts count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${record.cost.toStringAsFixed(0)} UAH',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (record.receiptPhotosUrls.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file, size: 13, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text(
                        '${record.receiptPhotosUrls.length} ${record.receiptPhotosUrls.length == 1 ? "чек" : "чеки"}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
