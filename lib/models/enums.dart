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
      return 'read';
    case TicketStatus.inProgress:
      return 'in_progress';
    case TicketStatus.resolved:
      return 'resolved';
    case TicketStatus.rejected:
      return 'rejected';
    case TicketStatus.unread:
    default:
      return 'unread';
  }
}
