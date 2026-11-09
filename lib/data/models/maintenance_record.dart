class MaintenanceRecord {
  final String id;
  final String vehicleId;
  final String category; // 'ТО', 'Ремонт', 'Паливо', 'Деталі', 'Інше'
  final String title;
  final int mileageAtService;
  final DateTime serviceDate;
  final double cost;
  final String workDescription;
  final String? serviceStationName;
  final List<String> receiptPhotosUrls;
  final DateTime? createdAt;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.category,
    required this.title,
    required this.mileageAtService,
    required this.serviceDate,
    required this.cost,
    required this.workDescription,
    this.serviceStationName,
    this.receiptPhotosUrls = const [],
    this.createdAt,
  });

  MaintenanceRecord copyWith({
    String? id,
    String? vehicleId,
    String? category,
    String? title,
    int? mileageAtService,
    DateTime? serviceDate,
    double? cost,
    String? workDescription,
    String? serviceStationName,
    List<String>? receiptPhotosUrls,
    DateTime? createdAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      category: category ?? this.category,
      title: title ?? this.title,
      mileageAtService: mileageAtService ?? this.mileageAtService,
      serviceDate: serviceDate ?? this.serviceDate,
      cost: cost ?? this.cost,
      workDescription: workDescription ?? this.workDescription,
      serviceStationName: serviceStationName ?? this.serviceStationName,
      receiptPhotosUrls: receiptPhotosUrls ?? this.receiptPhotosUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'category': category,
      'title': title,
      'mileageAtService': mileageAtService,
      'serviceDate': serviceDate.toIso8601String(),
      'cost': cost,
      'workDescription': workDescription,
      'serviceStationName': serviceStationName,
      'receiptPhotosUrls': receiptPhotosUrls,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      category: json['category'] as String? ?? 'ТО',
      title: json['title'] as String? ?? '',
      mileageAtService: (json['mileageAtService'] as num?)?.toInt() ?? 0,
      serviceDate: json['serviceDate'] != null
          ? DateTime.tryParse(json['serviceDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      workDescription: json['workDescription'] as String? ?? '',
      serviceStationName: json['serviceStationName'] as String?,
      receiptPhotosUrls: (json['receiptPhotosUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
