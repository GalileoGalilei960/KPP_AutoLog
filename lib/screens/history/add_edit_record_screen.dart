import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/maintenance_record.dart';

class AddEditRecordScreen extends StatefulWidget {
  final MaintenanceRecord? record;
  final String? defaultVehicleId;
  final String? vehicleName;
  final int? currentMileage;

  const AddEditRecordScreen({
    super.key,
    this.record,
    this.defaultVehicleId,
    this.vehicleName,
    this.currentMileage,
  });

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _mileageController;
  late TextEditingController _costController;
  late TextEditingController _stationController;
  late TextEditingController _descriptionController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  late List<String> _receipts;

  final List<String> _categories = const ['ТО', 'Ремонт', 'Паливо', 'Деталі'];

  bool get isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _titleController = TextEditingController(text: r?.title ?? '');
    _mileageController = TextEditingController(
      text: r != null ? '${r.mileageAtService}' : (widget.currentMileage != null ? '${widget.currentMileage}' : ''),
    );
    _costController = TextEditingController(
      text: r != null ? r.cost.toStringAsFixed(0) : '',
    );
    _stationController = TextEditingController(text: r?.serviceStationName ?? '');
    _descriptionController = TextEditingController(text: r?.workDescription ?? '');

    _selectedCategory = r?.category ?? 'Ремонт';
    _selectedDate = r?.serviceDate ?? DateTime.now();
    _receipts = List<String>.from(r?.receiptPhotosUrls ?? ['Чек за деталі (1.2 МБ)', 'Акт робіт (0.9 МБ)']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mileageController.dispose();
    _costController.dispose();
    _stationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final mileage = int.tryParse(_mileageController.text.replaceAll(' ', '').trim()) ?? 0;
    final cost = double.tryParse(_costController.text.replaceAll(' ', '').trim()) ?? 0.0;

    final record = MaintenanceRecord(
      id: widget.record?.id ?? 'rec_${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: widget.record?.vehicleId ?? widget.defaultVehicleId ?? 'car_1',
      category: _selectedCategory,
      title: _titleController.text.trim(),
      mileageAtService: mileage,
      serviceDate: _selectedDate,
      cost: cost,
      workDescription: _descriptionController.text.trim(),
      serviceStationName: _stationController.text.trim(),
      receiptPhotosUrls: _receipts,
      createdAt: widget.record?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(record);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Редагувати запис ТО' : 'Новий запис ТО / Ремонту'),
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
                    // Header
                    Text(
                      isEditing ? 'Редагування запису ТО / Ремонту' : 'Новий запис ТО / Ремонту',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.vehicleName != null
                          ? '${widget.vehicleName} · Облік витрат та робіт'
                          : 'Введіть деталі проведеного обслуговування чи ремонту',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Segmented Control
                    const Text(
                      'Категорія',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                          selectedColor: AppColors.primaryLight,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Content layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 650;

                        final leftForm = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Назва робіт',
                              hint: 'Заміна колодок',
                              controller: _titleController,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Введіть назву робіт' : null,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Пробіг (км)',
                                    hint: '184500',
                                    controller: _mileageController,
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty) ? 'Введіть пробіг' : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Дата',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: _pickDate,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 13,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.inputBorder),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatDate(_selectedDate),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                            ],
                                          ),
                                        ),
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
                                    label: 'Вартість (грн)',
                                    hint: '4250',
                                    controller: _costController,
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty) ? 'Введіть вартість' : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Назва СТО',
                                    hint: 'СТО «Автомайстер»',
                                    controller: _stationController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Опис виконаних робіт',
                              hint: 'Детальний перелік замінених деталей, стан вузлів...',
                              controller: _descriptionController,
                              maxLines: 3,
                            ),
                          ],
                        );

                        final rightReceipts = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Фото чеків та актів',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Перетягніть фото чеків сюди',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'JPG, PNG до 10 МБ на файл',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _receipts.add('Чек #${_receipts.length + 1}.png');
                                      });
                                    },
                                    icon: const Icon(Icons.add_photo_alternate, size: 16),
                                    label: const Text('Додати чек'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (_receipts.isNotEmpty) ...[
                              Text(
                                'Додані файли (${_receipts.length}):',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(_receipts.length, (index) {
                                final item = _receipts[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.receipt_long, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            item,
                                            style: const TextStyle(fontSize: 12.5),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 16, color: AppColors.dangerText),
                                        onPressed: () {
                                          setState(() => _receipts.removeAt(index));
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: leftForm),
                              const SizedBox(width: 28),
                              Expanded(flex: 4, child: rightReceipts),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              leftForm,
                              const SizedBox(height: 20),
                              rightReceipts,
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 28),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 20),

                    // Action buttons
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
                          width: 180,
                          child: AppButton.primary(
                            text: isEditing ? 'Зберегти зміни' : 'Зберегти запис',
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
