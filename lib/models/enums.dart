import 'package:flutter/material.dart' show Color;

enum Gender { male, female }

Gender? genderFromString(String? value) {
  if (value == null) return null;
  switch (value.toLowerCase()) {
    case 'male':
      return Gender.male;
    case 'female':
      return Gender.female;
    default:
      return null;
  }
}

String? genderToString(Gender? gender) {
  switch (gender) {
    case Gender.male:
      return 'male';
    case Gender.female:
      return 'female';
    default:
      return null;
  }
}

enum TicketStatus {
  unread,
  read,
  inProgress,
  resolved,
  rejected,
}

TicketStatus ticketStatusFromString(String status) {
  switch (status) {
    case 'read':
      return TicketStatus.read;
    case 'in_progress':
      return TicketStatus.inProgress;
    case 'resolved':
      return TicketStatus.resolved;
    case 'rejected':
      return TicketStatus.rejected;
    default:
      return TicketStatus.unread;
  }
}

String ticketStatusToString(TicketStatus status) {
  switch (status) {
    case TicketStatus.read:
      return 'Dibaca';
    case TicketStatus.inProgress:
      return 'Proses';
    case TicketStatus.resolved:
      return 'Diterima';
    case TicketStatus.rejected:
      return 'Ditolak';
    case TicketStatus.unread:
    return 'Belum Dibaca';
  }
}

extension TicketStatusExtension on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.unread:
        return 'Belum Dibaca';
      case TicketStatus.read:
        return 'Dibaca';
      case TicketStatus.inProgress:
        return 'Proses';
      case TicketStatus.resolved:
        return 'Diterima';
      case TicketStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.unread:
        return const Color(0xFFEF4444); // merah
      case TicketStatus.read:
        return const Color(0xFF3B82F6); // biru
      case TicketStatus.inProgress:
        return const Color(0xFFF59E0B); // oranye
      case TicketStatus.resolved:
        return const Color(0xFF10B981); // hijau
      case TicketStatus.rejected:
        return const Color(0xFF9CA3AF); // abu-abu
    }
  }
}