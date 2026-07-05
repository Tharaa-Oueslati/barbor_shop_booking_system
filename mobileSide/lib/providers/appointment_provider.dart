import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  List<Barber> _barbers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Appointment> get appointments => _appointments;
  List<Barber> get barbers => _barbers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Statistics
  int get totalAppointments => _appointments.length;
  int get pendingCount => _appointments.where((a) => a.status == AppointmentStatus.pending).length;
  int get confirmedCount => _appointments.where((a) => a.status == AppointmentStatus.confirmed).length;
  int get cancelledCount => _appointments.where((a) => a.status == AppointmentStatus.cancelled).length;

  List<Appointment> get pendingAppointments =>
      _appointments.where((a) => a.status == AppointmentStatus.pending).toList();

  List<Appointment> getFilteredAppointments(String filter) {
    if (filter == 'ALL') return _appointments;
    final status = AppointmentStatus.fromString(filter);
    return _appointments.where((a) => a.status == status).toList();
  }

  List<BarberStats> getTopBarbers() {
    final stats = <String, int>{};
    for (final appt in _appointments) {
      stats[appt.barberName] = (stats[appt.barberName] ?? 0) + 1;
    }

    return stats.entries
        .map((e) => BarberStats(name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  List<ServiceStats> getTopServices() {
    final stats = <String, int>{};
    for (final appt in _appointments) {
      stats[appt.haircutTypeName] = (stats[appt.haircutTypeName] ?? 0) + 1;
    }

    return stats.entries
        .map((e) => ServiceStats(name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  List<AppointmentGroup> getGroupedAppointments(List<Appointment> appointments) {
    final groups = <String, List<Appointment>>{};

    for (final appt in appointments) {
      if (!groups.containsKey(appt.date)) {
        groups[appt.date] = [];
      }
      groups[appt.date]!.add(appt);
    }

    return groups.entries.map((e) {
      e.value.sort((a, b) => a.startTime.compareTo(b.startTime));
      return AppointmentGroup(date: e.key, appointments: e.value);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> loadAllAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final api = ApiService();
      _appointments = await api.getAllAppointments();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> loadBarberAppointments(int barberId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final api = ApiService();
      _appointments = await api.getBarberAppointments(barberId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> loadBarbers() async {
    try {
      final api = ApiService();
      _barbers = await api.getActiveBarbers();
      notifyListeners();
    } catch (e) {
      // Silently fail for barbers
    }
  }

  Future<bool> confirmAppointment(int appointmentId) async {
    try {
      final api = ApiService();
      await api.confirmAppointment(appointmentId);

      // Update local state
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: AppointmentStatus.confirmed,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    try {
      final api = ApiService();
      await api.cancelAppointment(appointmentId);

      // Update local state
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: AppointmentStatus.cancelled,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class BarberStats {
  final String name;
  final int count;

  BarberStats({required this.name, required this.count});
}

class ServiceStats {
  final String name;
  final int count;

  ServiceStats({required this.name, required this.count});
}
