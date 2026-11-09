import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/vehicle.dart';
import '../../data/repositories/vehicles_repository.dart';
import 'garage_event.dart';
import 'garage_state.dart';

class GarageBloc extends Bloc<GarageEvent, GarageState> {
  final VehiclesRepository vehiclesRepository;

  GarageBloc({required this.vehiclesRepository})
      : super(const GarageInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicleEvent>(_onAddVehicle);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<SetActiveVehicleEvent>(_onSetActiveVehicle);
    on<FilterVehiclesEvent>(_onFilterVehicles);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<GarageState> emit,
  ) async {
    emit(const GarageLoading());
    try {
      final vehicles = await vehiclesRepository.getVehicles();
      final active = vehicles.isEmpty
          ? null
          : vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first);
      emit(GarageLoaded(
        allVehicles: vehicles,
        filteredVehicles: vehicles,
        activeVehicle: active,
      ));
    } catch (e) {
      emit(GarageError('Не вдалося завантажити автомобілі: $e'));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicleEvent event,
    Emitter<GarageState> emit,
  ) async {
    try {
      await vehiclesRepository.addVehicle(event.vehicle);
      final vehicles = await vehiclesRepository.getVehicles();
      final active = vehicles.firstWhere(
        (v) => v.isActive,
        orElse: () => vehicles.first,
      );
      final query = state is GarageLoaded ? (state as GarageLoaded).searchQuery : '';
      emit(GarageLoaded(
        allVehicles: vehicles,
        filteredVehicles: _applyFilter(vehicles, query),
        activeVehicle: active,
        searchQuery: query,
      ));
    } catch (e) {
      emit(GarageError('Не вдалося додати авто: $e'));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<GarageState> emit,
  ) async {
    try {
      await vehiclesRepository.updateVehicle(event.vehicle);
      final vehicles = await vehiclesRepository.getVehicles();
      final active = vehicles.firstWhere(
        (v) => v.isActive,
        orElse: () => vehicles.first,
      );
      final query = state is GarageLoaded ? (state as GarageLoaded).searchQuery : '';
      emit(GarageLoaded(
        allVehicles: vehicles,
        filteredVehicles: _applyFilter(vehicles, query),
        activeVehicle: active,
        searchQuery: query,
      ));
    } catch (e) {
      emit(GarageError('Не вдалося оновити авто: $e'));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<GarageState> emit,
  ) async {
    try {
      await vehiclesRepository.deleteVehicle(event.vehicleId);
      final vehicles = await vehiclesRepository.getVehicles();
      final active = vehicles.isEmpty
          ? null
          : vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first);
      final query = state is GarageLoaded ? (state as GarageLoaded).searchQuery : '';
      emit(GarageLoaded(
        allVehicles: vehicles,
        filteredVehicles: _applyFilter(vehicles, query),
        activeVehicle: active,
        searchQuery: query,
      ));
    } catch (e) {
      emit(GarageError('Не вдалося видалити авто: $e'));
    }
  }

  Future<void> _onSetActiveVehicle(
    SetActiveVehicleEvent event,
    Emitter<GarageState> emit,
  ) async {
    try {
      await vehiclesRepository.setActiveVehicle(event.vehicleId);
      final vehicles = await vehiclesRepository.getVehicles();
      final active = vehicles.firstWhere(
        (v) => v.isActive,
        orElse: () => vehicles.first,
      );
      final query = state is GarageLoaded ? (state as GarageLoaded).searchQuery : '';
      emit(GarageLoaded(
        allVehicles: vehicles,
        filteredVehicles: _applyFilter(vehicles, query),
        activeVehicle: active,
        searchQuery: query,
      ));
    } catch (e) {
      emit(GarageError('Не вдалося активувати авто: $e'));
    }
  }

  void _onFilterVehicles(
    FilterVehiclesEvent event,
    Emitter<GarageState> emit,
  ) {
    if (state is! GarageLoaded) return;
    final currentState = state as GarageLoaded;
    final filtered = _applyFilter(currentState.allVehicles, event.query);
    emit(currentState.copyWith(
      filteredVehicles: filtered,
      searchQuery: event.query,
    ));
  }

  List<Vehicle> _applyFilter(List<Vehicle> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase().trim();
    return list.where((v) {
      return v.make.toLowerCase().contains(q) ||
          v.model.toLowerCase().contains(q) ||
          (v.plateNumber?.toLowerCase().contains(q) ?? false) ||
          (v.vin?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
