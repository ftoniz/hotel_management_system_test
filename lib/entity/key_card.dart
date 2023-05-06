import 'guest.dart';
import 'room.dart';

class KeyCard {
  KeyCard({required this.number});

  int number;
  Room? _room;
  Room? get room => _room;

  bool get isUsing => room != null;

  Guest? get owner => _room?.owner;

  bool canSetupFor({required Room room}) => !isUsing && room.canCheckIn;
  bool canRetureKeyBy(String guestName) => isUsing && owner?.name == guestName;

  bool setupFor({
    required Room room,
    required Guest guest,
  }) {
    if (!canSetupFor(room: room)) return false;

    _room = room;
    _room?.checkInBy(guest);
    return true;
  }

  bool returnKeyBy(String guestName) {
    var canCheckout = _room?.canCheckOutBy(guestName) ?? false;
    if (!canRetureKeyBy(guestName) || !canCheckout) return false;

    _room?.checkOutBy(guestName);
    _room = null;
    return true;
  }
}
