import '../../data/models/maintenance_record.dart';

abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<MaintenanceRecord> allRecords;
  final List<MaintenanceRecord> filteredRecords;
  final String selectedCategory; // 'Всі', 'ТО', 'Ремонт', 'Паливо', 'Деталі'
  final String sortBy; // 'newest', 'oldest', 'cost_desc', 'cost_asc'
  final double totalExpenses;

  const HistoryLoaded({
    required this.allRecords,
    required this.filteredRecords,
    this.selectedCategory = 'Всі',
    this.sortBy = 'newest',
    required this.totalExpenses,
  });

  HistoryLoaded copyWith({
    List<MaintenanceRecord>? allRecords,
    List<MaintenanceRecord>? filteredRecords,
    String? selectedCategory,
    String? sortBy,
    double? totalExpenses,
  }) {
    return HistoryLoaded(
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      totalExpenses: totalExpenses ?? this.totalExpenses,
    );
  }
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
}
