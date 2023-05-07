import 'package:hotel_management_system/extensions/list_extensions.dart';

import 'guest.dart';
import 'key_card.dart';
import 'room.dart';

class Hotel {
  Hotel();

  static Hotel? _instance;
  static Hotel get instance => _instance ??= Hotel();

  List<Room> _rooms = [];
  List<KeyCard> _keyCards = [];
  bool _isAllowToSetup = true;
  bool get isAllowToSetup => _isAllowToSetup;
  bool get isReadyToUse => _rooms.isNotEmpty && _keyCards.isNotEmpty;

  void reset() {
    _rooms = [];
    _keyCards = [];
    _isAllowToSetup = true;
  }

  bool setup({
    required int numberOfFloor,
    required int numberOfRoomsPerFloor,
  }) {
    if (!_isAllowToSetup) return false;

    var currentFloor = 1;
    var currentRoomOnFloor = 0;
    var keyCardNumber = 1;
    List<Room> rooms = [];
    List<KeyCard> keyCards = [];
    while (currentFloor <= numberOfFloor) {
      if (currentRoomOnFloor >= numberOfRoomsPerFloor) {
        currentFloor += 1;
        currentRoomOnFloor = 0;
      } else {
        rooms.add(
          Room(
            status: RoomStatus.ready,
            floor: currentFloor,
            index: currentRoomOnFloor + 1,
          ),
        );
        keyCards.add(
          KeyCard(number: keyCardNumber),
        );

        currentRoomOnFloor += 1;
        keyCardNumber += 1;
      }
    }

    _rooms = rooms;
    _keyCards = keyCards;
    _isAllowToSetup = false;
    return true;
  }

  List<Guest> get guests => _keyCards
      .where((e) => e.isUsing)
      .map((e) => e.owner ?? Guest(name: '', age: -1))
      .where((e) => e.age != -1)
      .toList();

  // Room
  List<Room> get rooms => _rooms;

  List<Room> get findAvailableRooms =>
      _rooms.where((e) => e.status == RoomStatus.ready).toList();

  Room? getRoom({required String number}) =>
      _rooms.tryFirstWhere((room) => room.number == number);

  List<Room> findRoomsAtFloor(int floor) =>
      _rooms.where((e) => e.floor == floor).toList();

  // KeyCard
  List<KeyCard> get keyCards => _keyCards;

  KeyCard? findAvailableKeyCardFor({required Room room}) =>
      _keyCards.tryFirstWhere((e) => e.canSetupFor(room: room));

  KeyCard? getKeyCard({required int number}) =>
      _keyCards.tryFirstWhere((e) => e.number == number);

  List<KeyCard> findKeyCardsAtFloor(int floor) =>
      _keyCards.where((e) => e.room?.floor == floor).toList();

  List<KeyCard> findUsingKeyCardsAtFloor(int floor) =>
      _keyCards.where((e) => e.isUsing && e.room?.floor == floor).toList();

  bool checkout({required KeyCard keyCard, required String guestName}) {
    final canReturnKey = keyCard.canRetureKeyBy(guestName);
    if (!canReturnKey) {
      return false;
    }

    keyCard.returnKeyBy(guestName);
    return true;
  }

  void forceCheckout({required KeyCard keyCard}) {
    keyCard.forceRetureKey();
  }

  // Guest
  List<Guest> findGuestsAtFloor(int floor) => _keyCards
      .where((e) => e.isUsing && e.room?.floor == floor)
      .map((e) => e.owner ?? Guest(name: '', age: -1))
      .where((e) => e.age != -1)
      .toList();
}
