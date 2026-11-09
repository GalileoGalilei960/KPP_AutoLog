class Vehicle {
  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? plateNumber;
  final int currentMileage;
  final String fuelType; // Дизель, Бензин, Газ, Електро, Гібрид
  final String? photoUrl;
  final String? notes;
  final bool isActive;
  final DateTime? updatedAt;

  const Vehicle({
    required this.id,
    this.userId = '',
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.plateNumber,
    required this.currentMileage,
    this.fuelType = 'Дизель',
    this.photoUrl,
    this.notes,
    this.isActive = false,
    this.updatedAt,
  });

  String get displayName => '$make $model';

  String get subtitleInfo {
    final parts = <String>[];
    parts.add('$year рік');
    if (fuelType.isNotEmpty) parts.add(fuelType);
    if (plateNumber != null && plateNumber!.isNotEmpty) parts.add(plateNumber!);
    return parts.join(' · ');
  }

  Vehicle copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? plateNumber,
    int? currentMileage,
    String? fuelType,
    String? photoUrl,
    String? notes,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      plateNumber: plateNumber ?? this.plateNumber,
      currentMileage: currentMileage ?? this.currentMileage,
      fuelType: fuelType ?? this.fuelType,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'plateNumber': plateNumber,
      'currentMileage': currentMileage,
      'fuelType': fuelType,
      'photoUrl': photoUrl,
      'notes': notes,
      'isActive': isActive,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      vin: json['vin'] as String?,
      plateNumber: json['plateNumber'] as String?,
      currentMileage: (json['currentMileage'] as num?)?.toInt() ?? 0,
      fuelType: json['fuelType'] as String? ?? 'Бензин',
      photoUrl: json['photoUrl'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
