import 'guest.dart';
import 'key_card.dart';
import 'room.dart';

class Hotel {
  late final List<Room> _rooms;
  late final List<KeyCard> _keyCards;

  List<Room> get rooms => _rooms;
  List<KeyCard> get keyCards => _keyCards;
  List<Guest> get guests => _keyCards
      .where((e) => e.isUsing)
      .map((e) => e.owner ?? Guest(name: '', age: -1))
      .where((e) => e.age != -1)
      .toList();

  Hotel({
    required int floor,
    required int numberOfRoomsPerFloor,
  }) {
    var currentFloor = 1;
    var currentRoomOnFloor = 0;
    var keyCardNumber = 1;
    List<Room> rooms = [];
    List<KeyCard> keyCards = [];
    while (currentFloor <= floor) {
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
  }
}
