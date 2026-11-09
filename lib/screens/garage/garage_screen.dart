import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/garage/garage_bloc.dart';
import '../../blocs/garage/garage_event.dart';
import '../../blocs/garage/garage_state.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/vehicle.dart';
import 'add_edit_car_screen.dart';
import 'widgets/car_card.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'GarageScreen');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onAddCar(BuildContext context) async {
    final result = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(builder: (_) => const AddEditCarScreen()),
    );
    if (result != null && context.mounted) {
      context.read<GarageBloc>().add(AddVehicleEvent(result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Автомобіль "${result.displayName}" успішно додано!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onEditCar(BuildContext context, Vehicle vehicle) async {
    final result = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => AddEditCarScreen(vehicle: vehicle),
      ),
    );
    if (result != null && context.mounted) {
      context.read<GarageBloc>().add(UpdateVehicleEvent(result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Дані "${result.displayName}" оновлено!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onDeleteCar(BuildContext context, Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити автомобіль?'),
        content: Text(
          'Ви впевнені, що хочете видалити "${vehicle.displayName}" з гаража? Усі повʼязані записи залишаться в архіві.',
        ),
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
      context.read<GarageBloc>().add(DeleteVehicleEvent(vehicle.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Автомобіль "${vehicle.displayName}" видалено.'),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onSetActiveCar(BuildContext context, Vehicle vehicle) {
    context.read<GarageBloc>().add(SetActiveVehicleEvent(vehicle.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${vehicle.displayName}" обрано активним автомобілем.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, state) {
        if (state is GarageLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GarageError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.dangerText),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<GarageBloc>().add(const LoadVehicles()),
                  child: const Text('Спробувати знову'),
                ),
              ],
            ),
          );
        }

        final vehicles = state is GarageLoaded ? state.filteredVehicles : <Vehicle>[];
        final allCount = state is GarageLoaded ? state.allVehicles.length : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row with Title, Count badge and Add Button
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;

                  final titleSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Гараж автомобілів',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$allCount автомобілі',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Керуйте даними автомобілів та обирайте активний для обліку обслуговування.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );

                  final addButton = SizedBox(
                    width: 200,
                    child: AppButton.primary(
                      text: '+ Додати автомобіль',
                      onPressed: () => _onAddCar(context),
                    ),
                  );

                  if (isWide) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: titleSection),
                        addButton,
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        const SizedBox(height: 14),
                        addButton,
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Search Filter Row
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context.read<GarageBloc>().add(FilterVehiclesEvent(val));
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                    hintText: 'Пошук за маркою, моделлю, номером або VIN...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Vehicles Grid/List
              if (vehicles.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 56,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Автомобілів не знайдено',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Спробуйте змінити пошуковий запит або додайте нове авто',
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    // Responsive column count
                    final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

                    if (crossAxisCount == 1) {
                      // ListView for mobile
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vehicles.length,
                        itemBuilder: (ctx, index) {
                          final v = vehicles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CarCard(
                              vehicle: v,
                              onEdit: () => _onEditCar(context, v),
                              onDelete: () => _onDeleteCar(context, v),
                              onSetActive: () => _onSetActiveCar(context, v),
                            ),
                          );
                        },
                      );
                    }

                    // GridView.builder for desktop / wide tablet
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: 310,
                      ),
                      itemCount: vehicles.length,
                      itemBuilder: (ctx, index) {
                        final v = vehicles[index];
                        return CarCard(
                          vehicle: v,
                          onEdit: () => _onEditCar(context, v),
                          onDelete: () => _onDeleteCar(context, v),
                          onSetActive: () => _onSetActiveCar(context, v),
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Bottom Info Banner (Lab 2 Figure 5)
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 12,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.5),
                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Активний автомобіль відображається на головній панелі. Змінити його можна через меню картки.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
