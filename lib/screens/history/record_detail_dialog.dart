import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/maintenance_record.dart';

class RecordDetailDialog extends StatelessWidget {
  final MaintenanceRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecordDetailDialog({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required MaintenanceRecord record,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (_) => RecordDetailDialog(
        record: record,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tags row
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(record.category),
                    backgroundColor: AppColors.primaryLight,
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 14),
                    label: Text(_formatDate(record.serviceDate)),
                  ),
                  Chip(
                    avatar: const Icon(Icons.speed, size: 14),
                    label: Text('${record.mileageAtService} км'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Вартість робіт:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${record.cost.toStringAsFixed(0)} UAH',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (record.serviceStationName != null &&
                        record.serviceStationName!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Виконавець / СТО:',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            record.serviceStationName!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (record.workDescription.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Опис робіт:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.workDescription,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Attached receipts
              if (record.receiptPhotosUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Додані файли та чеки (${record.receiptPhotosUrls.length}):',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: record.receiptPhotosUrls.map((photo) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            photo,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.dangerText),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Видалити'),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Закрити'),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 130,
                        child: AppButton.primary(
                          text: 'Редагувати',
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEdit();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
