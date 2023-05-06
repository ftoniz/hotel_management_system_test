import 'package:sprintf/sprintf.dart';

import 'key_card.dart';
import 'room.dart';

class Hotel {
  late final List<Room> rooms;
  late final List<KeyCard> keyCards;

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
        var roomNumber = sprintf(
          '%01i%02i',
          [currentFloor, currentRoomOnFloor + 1],
        );
        rooms.add(
          Room(status: RoomStatus.ready, number: roomNumber),
        );
        keyCards.add(
          KeyCard(number: keyCardNumber),
        );

        currentRoomOnFloor += 1;
        keyCardNumber += 1;
      }
    }

    this.rooms = rooms;
    this.keyCards = keyCards;
  }
}
