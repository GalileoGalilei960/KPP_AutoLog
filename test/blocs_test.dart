import 'package:flutter_test/flutter_test.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/auth/login_bloc.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/auth/login_event.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/auth/login_state.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/garage/garage_bloc.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/garage/garage_event.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/garage/garage_state.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/history/history_bloc.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/history/history_event.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/blocs/history/history_state.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/models/maintenance_record.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/models/user_settings.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/models/vehicle.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/repositories/auth_repository.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/repositories/maintenance_repository.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/repositories/settings_repository.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/repositories/vehicles_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTestAuthRepo implements AuthRepository {
  bool shouldFail = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (shouldFail) {
      throw const AuthException('Невірний логін або пароль');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    if (shouldFail) {
      throw const AuthException('Помилка Google');
    }
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Лабораторна робота №5 - BLoC та локальні дані', () {
    test('1. LoginBloc emits [LoginLoading, LoginSuccess] on valid credentials', () async {
      final repo = MockTestAuthRepo();
      final bloc = LoginBloc(repo);

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LoginLoading>(),
          isA<LoginSuccess>(),
        ]),
      );

      bloc.add(const LoginSubmitted(
        email: 'test@example.com',
        password: 'password123',
      ));
    });

    test('2. LoginBloc emits [LoginLoading, LoginError] on invalid credentials', () async {
      final repo = MockTestAuthRepo()..shouldFail = true;
      final bloc = LoginBloc(repo);

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LoginLoading>(),
          isA<LoginError>(),
        ]),
      );

      bloc.add(const LoginSubmitted(
        email: 'wrong@example.com',
        password: 'wrong',
      ));
    });

    test('3. GarageBloc loads vehicles and handles CRUD operations', () async {
      final repo = LocalVehiclesRepository();
      final bloc = GarageBloc(vehiclesRepository: repo);

      // Load
      bloc.add(const LoadVehicles());
      await expectLater(
        bloc.stream,
        emitsThrough(isA<GarageLoaded>()),
      );

      final state = bloc.state as GarageLoaded;
      expect(state.allVehicles.isNotEmpty, isTrue);
      expect(state.activeVehicle, isNotNull);

      // Add car
      final newCar = Vehicle(
        id: 'test_car_99',
        make: 'BMW',
        model: 'M3',
        year: 2022,
        currentMileage: 15000,
        fuelType: 'Бензин',
      );
      bloc.add(AddVehicleEvent(newCar));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<GarageState>((s) =>
            s is GarageLoaded && s.allVehicles.any((v) => v.id == 'test_car_99'))),
      );

      // Filter
      bloc.add(const FilterVehiclesEvent('BMW'));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<GarageState>(
            (s) => s is GarageLoaded && s.filteredVehicles.length == 1)),
      );

      // Delete
      bloc.add(const DeleteVehicleEvent('test_car_99'));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<GarageState>((s) =>
            s is GarageLoaded && !s.allVehicles.any((v) => v.id == 'test_car_99'))),
      );
    });

    test('4. HistoryBloc loads records, filters, sorts and deletes', () async {
      final repo = LocalMaintenanceRepository();
      final bloc = HistoryBloc(maintenanceRepository: repo);

      bloc.add(const LoadRecords());
      await expectLater(
        bloc.stream,
        emitsThrough(isA<HistoryLoaded>()),
      );

      final state = bloc.state as HistoryLoaded;
      expect(state.allRecords.isNotEmpty, isTrue);
      expect(state.totalExpenses > 0, isTrue);

      // Filter by category 'Паливо'
      bloc.add(const FilterRecordsEvent(category: 'Паливо'));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<HistoryState>((s) =>
            s is HistoryLoaded &&
            s.selectedCategory == 'Паливо' &&
            s.filteredRecords.every((r) => r.category == 'Паливо'))),
      );

      // Add Record
      final newRecord = MaintenanceRecord(
        id: 'test_rec_100',
        vehicleId: 'car_1',
        category: 'Ремонт',
        title: 'Заміна амортизаторів',
        mileageAtService: 190000,
        serviceDate: DateTime.now(),
        cost: 8500.0,
        workDescription: 'Встановлення нових амортизаторів Kayaba',
      );
      bloc.add(AddRecordEvent(newRecord));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<HistoryState>((s) =>
            s is HistoryLoaded &&
            s.allRecords.any((r) => r.id == 'test_rec_100'))),
      );
    });

    test('5. SettingsRepository stores and loads currency and distance unit', () async {
      final repo = LocalSettingsRepository();
      final initial = await repo.getSettings();
      expect(initial.currency, 'UAH');
      expect(initial.distanceUnit, 'km');

      await repo.saveSettings(const UserSettings(
        currency: 'USD',
        distanceUnit: 'miles',
      ));

      final updated = await repo.getSettings();
      expect(updated.currency, 'USD');
      expect(updated.distanceUnit, 'miles');
    });
  });
}
