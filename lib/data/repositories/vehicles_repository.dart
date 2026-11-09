import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';

abstract class VehiclesRepository {
  Future<List<Vehicle>> getVehicles();
  Future<Vehicle> addVehicle(Vehicle vehicle);
  Future<Vehicle> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
  Future<void> setActiveVehicle(String id);
  Future<Vehicle?> getActiveVehicle();
}

class LocalVehiclesRepository implements VehiclesRepository {
  static const String _storageKey = 'saved_vehicles_v1';

  final List<Vehicle> _initialVehicles = [
    Vehicle(
      id: 'car_1',
      make: 'Volkswagen',
      model: 'Golf',
      year: 2015,
      fuelType: 'Дизель',
      plateNumber: 'BC 2837 TM',
      currentMileage: 184500,
      vin: 'WVWZZZAUZFW123456',
      photoUrl: 'assets/images/golf.jpg',
      notes: '1.6 TDI, механічна коробка передач. Заміна оливи на 184 950 км.',
      isActive: true,
      updatedAt: DateTime(2026, 10, 4),
    ),
    Vehicle(
      id: 'car_2',
      make: 'Audi',
      model: 'A8',
      year: 2003,
      fuelType: 'Дизель',
      plateNumber: 'BC 5522 AA',
      currentMileage: 220000,
      vin: 'WAUZZZ4E84N001234',
      notes: '4.2 TDI quattro, пневмопідвіска.',
      isActive: false,
      updatedAt: DateTime(2026, 9, 15),
    ),
    Vehicle(
      id: 'car_3',
      make: 'Mazda',
      model: 'CX-5',
      year: 2015,
      fuelType: 'Дизель',
      plateNumber: 'BC 0141 TB',
      currentMileage: 170000,
      vin: 'JM3KE2DY6F0123456',
      notes: '2.2 SkyActiv-D, повний привід.',
      isActive: false,
      updatedAt: DateTime(2026, 8, 20),
    ),
  ];

  @override
  Future<List<Vehicle>> getVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_storageKey);
      if (dataStr != null && dataStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(dataStr);
        final vehicles = list
            .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
            .toList();
        if (vehicles.isNotEmpty) {
          return vehicles;
        }
      }
    } catch (_) {}

    // Якщо сховище пусте — зберігаємо початкові машини
    await _saveToStorage(_initialVehicles);
    return List.from(_initialVehicles);
  }

  @override
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    final list = await getVehicles();
    // Якщо нове авто позначено активним, інші скидаємо
    final updatedList = list.map((v) {
      if (vehicle.isActive) {
        return v.copyWith(isActive: false);
      }
      return v;
    }).toList();

    updatedList.insert(0, vehicle);
    await _saveToStorage(updatedList);
    return vehicle;
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    final list = await getVehicles();
    final updatedList = list.map((v) {
      if (v.id == vehicle.id) {
        return vehicle;
      }
      if (vehicle.isActive && v.id != vehicle.id) {
        return v.copyWith(isActive: false);
      }
      return v;
    }).toList();

    await _saveToStorage(updatedList);
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    final list = await getVehicles();
    final updatedList = list.where((v) => v.id != id).toList();
    // Якщо видалили активне авто і ще залишились авто, робимо перше активним
    if (updatedList.isNotEmpty && !updatedList.any((v) => v.isActive)) {
      updatedList[0] = updatedList[0].copyWith(isActive: true);
    }
    await _saveToStorage(updatedList);
  }

  @override
  Future<void> setActiveVehicle(String id) async {
    final list = await getVehicles();
    final updatedList = list.map((v) {
      return v.copyWith(isActive: v.id == id);
    }).toList();
    await _saveToStorage(updatedList);
  }

  @override
  Future<Vehicle?> getActiveVehicle() async {
    final list = await getVehicles();
    if (list.isEmpty) return null;
    return list.firstWhere(
      (v) => v.isActive,
      orElse: () => list.first,
    );
  }

  Future<void> _saveToStorage(List<Vehicle> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((v) => v.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }
}
