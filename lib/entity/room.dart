import 'guest.dart';

enum RoomStatus { ready, using }

class Room {
  Room({
    required RoomStatus status,
    required this.number,
  }) {
    _status = status;
  }

  final String number;
  late RoomStatus _status;
  Guest? _owner;

  RoomStatus get status => _status;
  Guest? get owner => _owner;

  bool get canCheckIn => _owner == null;
  bool canCheckOutBy(String guestName) => _owner?.name == guestName;

  bool checkInBy(Guest guest) {
    if (!canCheckIn) {
      return false;
    }

    _owner = guest;
    _status = RoomStatus.using;
    return true;
  }

  bool checkOutBy(String guestName) {
    if (canCheckOutBy(guestName)) {
      return false;
    }

    _owner = null;
    _status = RoomStatus.ready;
    return true;
  }
}
