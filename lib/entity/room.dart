import 'package:sprintf/sprintf.dart';

import 'guest.dart';

enum RoomStatus { ready, using }

class Room {
  Room({
    required RoomStatus status,
    required this.index,
    required this.floor,
  }) {
    _status = status;
    number = sprintf(
      '%01i%02i',
      [floor, index],
    );
  }

  final int floor;
  final int index;
  late final String number;
  late RoomStatus _status;
  Guest? _owner;

  RoomStatus get status => _status;
  Guest? get owner => _owner;

  bool get canCheckIn => _owner == null;
  bool canCheckoutBy(String guestName) => _owner?.name == guestName;

  bool checkInBy(Guest guest) {
    if (!canCheckIn) {
      return false;
    }

    _owner = guest;
    _status = RoomStatus.using;
    return true;
  }

  bool checkoutBy(String guestName) {
    if (!canCheckoutBy(guestName)) {
      return false;
    }

    _owner = null;
    _status = RoomStatus.ready;
    return true;
  }

  void forceCheckout() {
    _owner = null;
    _status = RoomStatus.ready;
  }
}
