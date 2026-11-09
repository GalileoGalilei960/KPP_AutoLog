import '../../data/models/maintenance_record.dart';

abstract class HistoryEvent {
  const HistoryEvent();
}

class LoadRecords extends HistoryEvent {
  final String? vehicleId;
  const LoadRecords({this.vehicleId});
}

class AddRecordEvent extends HistoryEvent {
  final MaintenanceRecord record;
  const AddRecordEvent(this.record);
}

class UpdateRecordEvent extends HistoryEvent {
  final MaintenanceRecord record;
  const UpdateRecordEvent(this.record);
}

class DeleteRecordEvent extends HistoryEvent {
  final String recordId;
  const DeleteRecordEvent(this.recordId);
}

class FilterRecordsEvent extends HistoryEvent {
  final String? category;
  final String? sortBy; // 'newest', 'oldest', 'cost_desc', 'cost_asc'

  const FilterRecordsEvent({
    this.category,
    this.sortBy,
  });
}
