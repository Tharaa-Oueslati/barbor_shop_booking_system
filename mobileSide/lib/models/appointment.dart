enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }

  static AppointmentStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppointmentStatus.pending;
      case 'CONFIRMED':
        return AppointmentStatus.confirmed;
      case 'CANCELLED':
        return AppointmentStatus.cancelled;
      case 'COMPLETED':
        return AppointmentStatus.completed;
      default:
        return AppointmentStatus.pending;
    }
  }
}

class Appointment {
  final int id;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;
  final int barberId;
  final String barberName;
  final int haircutTypeId;
  final String haircutTypeName;
  final String date;
  final String startTime;
  final String? endTime;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    required this.barberId,
    required this.barberName,
    required this.haircutTypeId,
    required this.haircutTypeName,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      clientName: json['clientName'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      clientEmail: json['clientEmail'],
      barberId: json['barberId'] ?? 0,
      barberName: json['barberName'] ?? '',
      haircutTypeId: json['haircutTypeId'] ?? 0,
      haircutTypeName: json['haircutTypeName'] ?? '',
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'],
      status: AppointmentStatus.fromString(json['status'] ?? 'PENDING'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'barberId': barberId,
      'barberName': barberName,
      'haircutTypeId': haircutTypeId,
      'haircutTypeName': haircutTypeName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': status.name.toUpperCase(),
    };
  }

  Appointment copyWith({AppointmentStatus? status}) {
    return Appointment(
      id: id,
      clientName: clientName,
      clientPhone: clientPhone,
      clientEmail: clientEmail,
      barberId: barberId,
      barberName: barberName,
      haircutTypeId: haircutTypeId,
      haircutTypeName: haircutTypeName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
    );
  }
}

class AppointmentGroup {
  final String date;
  final List<Appointment> appointments;

  AppointmentGroup({required this.date, required this.appointments});

  String get formattedDate {
    try {
      final parts = date.split('-');
      final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return '${_weekday(d.weekday)}, ${_month(d.month)} ${d.day}';
    } catch (_) {
      return date;
    }
  }

  String _weekday(int w) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[w - 1];
  }

  String _month(int m) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[m - 1];
  }
}
