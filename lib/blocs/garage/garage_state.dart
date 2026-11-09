import '../../data/models/vehicle.dart';

abstract class GarageState {
  const GarageState();
}

class GarageInitial extends GarageState {
  const GarageInitial();
}

class GarageLoading extends GarageState {
  const GarageLoading();
}

class GarageLoaded extends GarageState {
  final List<Vehicle> allVehicles;
  final List<Vehicle> filteredVehicles;
  final Vehicle? activeVehicle;
  final String searchQuery;

  const GarageLoaded({
    required this.allVehicles,
    required this.filteredVehicles,
    this.activeVehicle,
    this.searchQuery = '',
  });

  GarageLoaded copyWith({
    List<Vehicle>? allVehicles,
    List<Vehicle>? filteredVehicles,
    Vehicle? activeVehicle,
    String? searchQuery,
  }) {
    return GarageLoaded(
      allVehicles: allVehicles ?? this.allVehicles,
      filteredVehicles: filteredVehicles ?? this.filteredVehicles,
      activeVehicle: activeVehicle ?? this.activeVehicle,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class GarageError extends GarageState {
  final String message;
  const GarageError(this.message);
}
