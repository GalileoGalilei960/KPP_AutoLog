import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/garage/garage_bloc.dart';
import '../../blocs/garage/garage_state.dart';
import '../../blocs/history/history_bloc.dart';
import '../../blocs/history/history_event.dart';
import '../../blocs/history/history_state.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/maintenance_record.dart';
import '../../data/models/vehicle.dart';
import 'add_edit_record_screen.dart';
import 'record_detail_dialog.dart';
import 'widgets/record_list_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _categories = const ['Всі', 'ТО', 'Ремонт', 'Паливо', 'Деталі'];

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'HistoryScreen');
  }

  Future<void> _onAddRecord(BuildContext context, Vehicle? activeCar) async {
    final result = await Navigator.of(context).push<MaintenanceRecord>(
      MaterialPageRoute(
        builder: (_) => AddEditRecordScreen(
          defaultVehicleId: activeCar?.id ?? 'car_1',
          vehicleName: activeCar?.displayName ?? 'Volkswagen Golf',
          currentMileage: activeCar?.currentMileage,
        ),
      ),
    );

    if (result != null && context.mounted) {
      context.read<HistoryBloc>().add(AddRecordEvent(result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Запис "${result.title}" додано!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onEditRecord(BuildContext context, MaintenanceRecord record, Vehicle? activeCar) async {
    final result = await Navigator.of(context).push<MaintenanceRecord>(
      MaterialPageRoute(
        builder: (_) => AddEditRecordScreen(
          record: record,
          vehicleName: activeCar?.displayName,
          currentMileage: activeCar?.currentMileage,
        ),
      ),
    );

    if (result != null && context.mounted) {
      context.read<HistoryBloc>().add(UpdateRecordEvent(result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Запис "${result.title}" оновлено!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onDeleteRecord(BuildContext context, MaintenanceRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити запис?'),
        content: Text('Ви дійсно бажаєте видалити запис "${record.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerText,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<HistoryBloc>().add(DeleteRecordEvent(record.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Запис "${record.title}" видалено.'),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Отримуємо активне авто з GarageBloc для шапки журналу
    final garageState = context.watch<GarageBloc>().state;
    final activeCar = garageState is GarageLoaded ? garageState.activeVehicle : null;

    final carTitle = activeCar != null ? 'Журнал ${activeCar.displayName}' : 'Журнал Volkswagen Golf';
    final carSubtitle = activeCar != null
        ? '${activeCar.subtitleInfo} · Поточний пробіг: ${activeCar.currentMileage} км'
        : '2015 · 1.6 TDI · Дизель · BC 2837 TM · Поточний пробіг: 184 500 км';

    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HistoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.dangerText),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<HistoryBloc>().add(const LoadRecords()),
                  child: const Text('Повторити'),
                ),
              ],
            ),
          );
        }

        final records = state is HistoryLoaded ? state.filteredRecords : <MaintenanceRecord>[];
        final currentCategory = state is HistoryLoaded ? state.selectedCategory : 'Всі';
        final currentSort = state is HistoryLoaded ? state.sortBy : 'newest';
        final totalExpenses = state is HistoryLoaded ? state.totalExpenses : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row with Active Car Info and Add Record Button
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;

                  final headerInfo = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Історія обслуговування · $carSubtitle',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );

                  final addRecordBtn = SizedBox(
                    width: 170,
                    child: AppButton.primary(
                      text: '+ Додати запис',
                      onPressed: () => _onAddRecord(context, activeCar),
                    ),
                  );

                  if (isWide) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: headerInfo),
                        addRecordBtn,
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerInfo,
                        const SizedBox(height: 14),
                        addRecordBtn,
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Filter Chips & Sort Dropdown Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Categories chips
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = currentCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat == 'Всі' ? '✓ Всі' : cat),
                              selected: isSelected,
                              onSelected: (_) {
                                context.read<HistoryBloc>().add(
                                      FilterRecordsEvent(category: cat),
                                    );
                              },
                              selectedColor: AppColors.primaryLight,
                              labelStyle: TextStyle(
                                fontSize: 13,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Sort Menu
                  PopupMenuButton<String>(
                    tooltip: 'Сортування',
                    initialValue: currentSort,
                    onSelected: (val) {
                      context.read<HistoryBloc>().add(FilterRecordsEvent(sortBy: val));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            currentSort == 'newest'
                                ? 'Спочатку нові'
                                : (currentSort == 'oldest' ? 'Спочатку старі' : 'За вартістю'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: 'newest', child: Text('Спочатку нові')),
                      PopupMenuItem(value: 'oldest', child: Text('Спочатку старі')),
                      PopupMenuItem(value: 'cost_desc', child: Text('За вартістю (спадання)')),
                      PopupMenuItem(value: 'cost_asc', child: Text('За вартістю (зростання)')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Records List using ListView.separated (Methodology p. 16)
              if (records.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Записів не знайдено',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'У цій категорії ще немає збережених записів ТО чи витрат',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final record = records[index];
                    return RecordListItem(
                      record: record,
                      onTap: () {
                        RecordDetailDialog.show(
                          context,
                          record: record,
                          onEdit: () => _onEditRecord(context, record, activeCar),
                          onDelete: () => _onDeleteRecord(context, record),
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Summary Footer (Lab 2 Figure 7)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Показано: ${records.length} записів',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Усі витрати: ${totalExpenses.toStringAsFixed(0)} UAH',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
