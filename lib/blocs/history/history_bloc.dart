import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/maintenance_record.dart';
import '../../data/repositories/maintenance_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final MaintenanceRepository maintenanceRepository;
  String? _currentVehicleId;

  HistoryBloc({required this.maintenanceRepository})
      : super(const HistoryInitial()) {
    on<LoadRecords>(_onLoadRecords);
    on<AddRecordEvent>(_onAddRecord);
    on<UpdateRecordEvent>(_onUpdateRecord);
    on<DeleteRecordEvent>(_onDeleteRecord);
    on<FilterRecordsEvent>(_onFilterRecords);
  }

  Future<void> _onLoadRecords(
    LoadRecords event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      _currentVehicleId = event.vehicleId;
      final records = await maintenanceRepository.getRecords(
        vehicleId: _currentVehicleId,
      );
      final sortedAndFiltered = _processRecords(records, 'Всі', 'newest');
      final total = _calcTotal(records);
      emit(HistoryLoaded(
        allRecords: records,
        filteredRecords: sortedAndFiltered,
        selectedCategory: 'Всі',
        sortBy: 'newest',
        totalExpenses: total,
      ));
    } catch (e) {
      emit(HistoryError('Не вдалося завантажити історію: $e'));
    }
  }

  Future<void> _onAddRecord(
    AddRecordEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await maintenanceRepository.addRecord(event.record);
      final records = await maintenanceRepository.getRecords(
        vehicleId: _currentVehicleId,
      );
      final currentCategory =
          state is HistoryLoaded ? (state as HistoryLoaded).selectedCategory : 'Всі';
      final currentSort =
          state is HistoryLoaded ? (state as HistoryLoaded).sortBy : 'newest';
      emit(HistoryLoaded(
        allRecords: records,
        filteredRecords: _processRecords(records, currentCategory, currentSort),
        selectedCategory: currentCategory,
        sortBy: currentSort,
        totalExpenses: _calcTotal(records),
      ));
    } catch (e) {
      emit(HistoryError('Не вдалося додати запис: $e'));
    }
  }

  Future<void> _onUpdateRecord(
    UpdateRecordEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await maintenanceRepository.updateRecord(event.record);
      final records = await maintenanceRepository.getRecords(
        vehicleId: _currentVehicleId,
      );
      final currentCategory =
          state is HistoryLoaded ? (state as HistoryLoaded).selectedCategory : 'Всі';
      final currentSort =
          state is HistoryLoaded ? (state as HistoryLoaded).sortBy : 'newest';
      emit(HistoryLoaded(
        allRecords: records,
        filteredRecords: _processRecords(records, currentCategory, currentSort),
        selectedCategory: currentCategory,
        sortBy: currentSort,
        totalExpenses: _calcTotal(records),
      ));
    } catch (e) {
      emit(HistoryError('Не вдалося оновити запис: $e'));
    }
  }

  Future<void> _onDeleteRecord(
    DeleteRecordEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await maintenanceRepository.deleteRecord(event.recordId);
      final records = await maintenanceRepository.getRecords(
        vehicleId: _currentVehicleId,
      );
      final currentCategory =
          state is HistoryLoaded ? (state as HistoryLoaded).selectedCategory : 'Всі';
      final currentSort =
          state is HistoryLoaded ? (state as HistoryLoaded).sortBy : 'newest';
      emit(HistoryLoaded(
        allRecords: records,
        filteredRecords: _processRecords(records, currentCategory, currentSort),
        selectedCategory: currentCategory,
        sortBy: currentSort,
        totalExpenses: _calcTotal(records),
      ));
    } catch (e) {
      emit(HistoryError('Не вдалося видалити запис: $e'));
    }
  }

  void _onFilterRecords(
    FilterRecordsEvent event,
    Emitter<HistoryState> emit,
  ) {
    if (state is! HistoryLoaded) return;
    final currentState = state as HistoryLoaded;
    final newCategory = event.category ?? currentState.selectedCategory;
    final newSort = event.sortBy ?? currentState.sortBy;

    final processed = _processRecords(
      currentState.allRecords,
      newCategory,
      newSort,
    );

    emit(currentState.copyWith(
      filteredRecords: processed,
      selectedCategory: newCategory,
      sortBy: newSort,
    ));
  }

  List<MaintenanceRecord> _processRecords(
    List<MaintenanceRecord> records,
    String category,
    String sortBy,
  ) {
    var result = List<MaintenanceRecord>.from(records);

    if (category != 'Всі') {
      result = result.where((r) => r.category == category).toList();
    }

    switch (sortBy) {
      case 'newest':
        result.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
        break;
      case 'oldest':
        result.sort((a, b) => a.serviceDate.compareTo(b.serviceDate));
        break;
      case 'cost_desc':
        result.sort((a, b) => b.cost.compareTo(a.cost));
        break;
      case 'cost_asc':
        result.sort((a, b) => a.cost.compareTo(b.cost));
        break;
    }

    return result;
  }

  double _calcTotal(List<MaintenanceRecord> records) {
    return records.fold(0.0, (sum, r) => sum + r.cost);
  }
}
