import '../../data/models/vehicle.dart';

abstract class GarageEvent {
  const GarageEvent();
}

class LoadVehicles extends GarageEvent {
  const LoadVehicles();
}

class AddVehicleEvent extends GarageEvent {
  final Vehicle vehicle;
  const AddVehicleEvent(this.vehicle);
}

class UpdateVehicleEvent extends GarageEvent {
  final Vehicle vehicle;
  const UpdateVehicleEvent(this.vehicle);
}

class DeleteVehicleEvent extends GarageEvent {
  final String vehicleId;
  const DeleteVehicleEvent(this.vehicleId);
}

class SetActiveVehicleEvent extends GarageEvent {
  final String vehicleId;
  const SetActiveVehicleEvent(this.vehicleId);
}

class FilterVehiclesEvent extends GarageEvent {
  final String query;
  const FilterVehiclesEvent(this.query);
}
