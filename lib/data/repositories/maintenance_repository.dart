import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/maintenance_record.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRecord>> getRecords({String? vehicleId});
  Future<MaintenanceRecord> addRecord(MaintenanceRecord record);
  Future<MaintenanceRecord> updateRecord(MaintenanceRecord record);
  Future<void> deleteRecord(String id);
}

class LocalMaintenanceRepository implements MaintenanceRepository {
  static const String _storageKey = 'saved_maintenance_records_v1';

  final List<MaintenanceRecord> _initialRecords = [
    MaintenanceRecord(
      id: 'rec_1',
      vehicleId: 'car_1',
      category: 'Ремонт',
      title: 'Заміна колодок',
      mileageAtService: 184150,
      serviceDate: DateTime(2026, 9, 28),
      cost: 4250.0,
      workDescription:
          'Заміна задніх гальмівних колодок. Перевірено диски та рівень гальмівної рідини.',
      serviceStationName: 'СТО «Автомайстер»',
      receiptPhotosUrls: ['receipt_1.jpg', 'receipt_2.jpg'],
      createdAt: DateTime(2026, 9, 28),
    ),
    MaintenanceRecord(
      id: 'rec_2',
      vehicleId: 'car_1',
      category: 'Паливо',
      title: 'Заправка дизелем · 42 л',
      mileageAtService: 183850,
      serviceDate: DateTime(2026, 9, 24),
      cost: 2394.0,
      workDescription: 'Повний бак пального Дизель Pulls, 42 літри.',
      serviceStationName: 'АЗК «ОККО»',
      receiptPhotosUrls: ['receipt_fuel.jpg'],
      createdAt: DateTime(2026, 9, 24),
    ),
    MaintenanceRecord(
      id: 'rec_3',
      vehicleId: 'car_1',
      category: 'ТО',
      title: 'Заміна повітряного та салонного фільтрів',
      mileageAtService: 183240,
      serviceDate: DateTime(2026, 6, 12),
      cost: 1680.0,
      workDescription: 'Планова заміна фільтра повітря двигуна та вугільного фільтра салону.',
      serviceStationName: 'СТО «Дизель Сервіс»',
      receiptPhotosUrls: ['receipt_filters.jpg'],
      createdAt: DateTime(2026, 6, 12),
    ),
    MaintenanceRecord(
      id: 'rec_4',
      vehicleId: 'car_1',
      category: 'Деталі',
      title: 'Комплект щіток склоочисника',
      mileageAtService: 181900,
      serviceDate: DateTime(2026, 5, 23),
      cost: 890.0,
      workDescription: 'Встановлення нових безкаркасних щіток Bosch Aerotwin.',
      serviceStationName: 'Магазин «Автодеталі»',
      receiptPhotosUrls: ['receipt_wipers.jpg'],
      createdAt: DateTime(2026, 5, 23),
    ),
    MaintenanceRecord(
      id: 'rec_5',
      vehicleId: 'car_1',
      category: 'ТО',
      title: 'Заміна моторної оливи та фільтра',
      mileageAtService: 174950,
      serviceDate: DateTime(2026, 4, 15),
      cost: 3100.0,
      workDescription:
          'Моторна олива Motul 8100 X-clean 5W-30 (4.5 л) та оригінальний масляний фільтр.',
      serviceStationName: 'СТО «Дизель Сервіс»',
      receiptPhotosUrls: ['receipt_oil_1.jpg', 'receipt_oil_2.jpg'],
      createdAt: DateTime(2026, 4, 15),
    ),
  ];

  @override
  Future<List<MaintenanceRecord>> getRecords({String? vehicleId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_storageKey);
      if (dataStr != null && dataStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(dataStr);
        final records = list
            .map((item) => MaintenanceRecord.fromJson(item as Map<String, dynamic>))
            .toList();
        if (records.isNotEmpty) {
          if (vehicleId != null && vehicleId.isNotEmpty) {
            return records.where((r) => r.vehicleId == vehicleId).toList();
          }
          return records;
        }
      }
    } catch (_) {}

    await _saveToStorage(_initialRecords);
    if (vehicleId != null && vehicleId.isNotEmpty) {
      return _initialRecords.where((r) => r.vehicleId == vehicleId).toList();
    }
    return List.from(_initialRecords);
  }

  @override
  Future<MaintenanceRecord> addRecord(MaintenanceRecord record) async {
    final list = await getRecords();
    list.insert(0, record);
    await _saveToStorage(list);
    return record;
  }

  @override
  Future<MaintenanceRecord> updateRecord(MaintenanceRecord record) async {
    final list = await getRecords();
    final updatedList = list.map((r) => r.id == record.id ? record : r).toList();
    await _saveToStorage(updatedList);
    return record;
  }

  @override
  Future<void> deleteRecord(String id) async {
    final list = await getRecords();
    final updatedList = list.where((r) => r.id != id).toList();
    await _saveToStorage(updatedList);
  }

  Future<void> _saveToStorage(List<MaintenanceRecord> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }
}
