import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/vehicle.dart';

class AddEditCarScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddEditCarScreen({
    super.key,
    this.vehicle,
  });

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;
  late TextEditingController _plateController;
  late TextEditingController _vinController;
  late TextEditingController _notesController;

  late String _selectedFuel;
  late bool _isActive;
  String? _photoUrl;

  final List<String> _fuelTypes = const [
    'Дизель',
    'Бензин',
    'Газ',
    'Електро',
    'Гібрид',
  ];

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(text: v != null ? '${v.year}' : '2020');
    _mileageController = TextEditingController(text: v != null ? '${v.currentMileage}' : '');
    _plateController = TextEditingController(text: v?.plateNumber ?? '');
    _vinController = TextEditingController(text: v?.vin ?? '');
    _notesController = TextEditingController(text: v?.notes ?? '');

    _selectedFuel = v?.fuelType ?? 'Дизель';
    _isActive = v?.isActive ?? false;
    _photoUrl = v?.photoUrl ?? 'assets/images/golf.jpg';
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _plateController.dispose();
    _vinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final year = int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;
    final mileage = int.tryParse(_mileageController.text.replaceAll(' ', '').trim()) ?? 0;

    final vehicle = Vehicle(
      id: widget.vehicle?.id ?? 'car_${DateTime.now().millisecondsSinceEpoch}',
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: year,
      fuelType: _selectedFuel,
      plateNumber: _plateController.text.trim().toUpperCase(),
      currentMileage: mileage,
      vin: _vinController.text.trim().toUpperCase(),
      notes: _notesController.text.trim(),
      photoUrl: _photoUrl,
      isActive: _isActive,
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Редагування автомобіля' : 'Додати автомобіль'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Назад',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: AppCard(
              padding: const EdgeInsets.all(28),
              borderRadius: 20,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title section
                    Text(
                      isEditing ? 'Редагування автомобіля' : 'Створення нового автомобіля',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Оновіть дані автомобіля. Вони використовуються для обліку пробігу та нагадувань.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Content layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 650;

                        final photoSection = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Фото автомобіля',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  border: Border.all(
                                    color: AppColors.border,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (_photoUrl != null && _photoUrl!.isNotEmpty)
                                      Image.asset(
                                        _photoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.directions_car, size: 64, color: Colors.black26),
                                        ),
                                      )
                                    else
                                      const Center(
                                        child: Icon(Icons.directions_car, size: 64, color: Colors.black26),
                                      ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                                          foregroundColor: AppColors.textPrimary,
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Фото збережено для демонстрації'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.upload_file, size: 16),
                                        label: const Text('Завантажити фото'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Активний автомобіль',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: const Text(
                                'Цей автомобіль відображається на головній панелі',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              value: _isActive,
                              onChanged: (val) {
                                setState(() => _isActive = val ?? false);
                              },
                              activeColor: AppColors.primary,
                            ),
                          ],
                        );

                        final formFieldsSection = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Марка',
                                    hint: 'Volkswagen',
                                    controller: _makeController,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty) ? "Введіть марку" : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Модель',
                                    hint: 'Golf',
                                    controller: _modelController,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty) ? "Введіть модель" : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Рік випуску',
                                    hint: '2015',
                                    controller: _yearController,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final y = int.tryParse(v ?? '');
                                      if (y == null || y < 1900 || y > 2030) {
                                        return 'Вкажіть коректний рік';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Тип пального',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: _selectedFuel,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                        ),
                                        items: _fuelTypes.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() => _selectedFuel = val);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Поточний пробіг (км)',
                                    hint: '184500',
                                    controller: _mileageController,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Введіть пробіг';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Номерний знак',
                                    hint: 'BC 2837 TM',
                                    controller: _plateController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'VIN код',
                              hint: 'WVWZZZAUZFW123456',
                              controller: _vinController,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Примітки',
                              hint: 'Особливості комплектації, інтервал ТО...',
                              controller: _notesController,
                              maxLines: 2,
                            ),
                          ],
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: photoSection),
                              const SizedBox(width: 28),
                              Expanded(flex: 6, child: formFieldsSection),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              photoSection,
                              const SizedBox(height: 20),
                              formFieldsSection,
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 28),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 20),

                    // Actions bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Скасувати'),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 160,
                          child: AppButton.primary(
                            text: 'Зберегти',
                            onPressed: _onSave,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
