import 'dart:io';

import 'package:hotel_management_system/entity/command.dart';
import 'package:hotel_management_system/entity/guest.dart';
import 'package:hotel_management_system/entity/hotel.dart';
import 'package:hotel_management_system/entity/key_card.dart';
import 'package:hotel_management_system/entity/room.dart';

Hotel? _hotel;

void main(List<String> arguments) {
  runCommands();
}

void runCommands() async {
  final fileName = 'input.txt';
  final fileData = await getStringFromFileName(fileName: fileName);
  final commands = getCommandsFromString(fileData);

  final results = commands.map((command) => executeCommand(command)).join('\n');
  print(results);
}

Future<String> getStringFromFileName({
  required String fileName,
}) async =>
    await File(fileName).readAsString();

List<Command> getCommandsFromString(
  String input,
) =>
    input
        .split('\n')
        .map((command) => generateCommand(command: command))
        .where((command) => command is! UnknownCommand && command.isValid)
        .toList();

String executeCommand(Command command) {
  if (command is CreateHotelCommand) {
    return executeCreateHotelComamnd(command);
  } else if (command is BookRoomCommand) {
    return executeBookRoomCommand(command);
  } else if (command is CheckoutRoomCommand) {
    return executeCheckoutRoomCommand(command);
  } else if (command is ListAvailableRoomsCommand) {
    return executeListAvailableRoomsCommand(command);
  } else if (command is ListGuestCommand) {
    return executeListGuestCommand(command);
  } else if (command is GetGuestInRoomCommand) {
    return executeGetGuestInRoomCommand(command);
  } else if (command is ListGuestByAgeCommand) {
    return executeListGuestByAgeCommand(command);
  } else if (command is ListGuestByFloorCommand) {
    return executeListGuestByFloorCommand(command);
  } else if (command is CheckoutGuestByFloorCommand) {
    return executeCheckoutGuestByFloorCommand(command);
  } else if (command is BookRoomsByFloorCommand) {
    return executeBookRoomsByFloorCommand(command);
  }
  return '';
}

/// This function is for createing the hotel
/// It can execute only one time
/// On other times will be rejected
String executeCreateHotelComamnd(CreateHotelCommand command) {
  if (_hotel != null) {
    return 'The hotel had already created';
  }

  _hotel = Hotel(
    floor: command.numberOfFloor,
    numberOfRoomsPerFloor: command.numberOfRoomsPerFloor,
  );

  return 'Hotel created with ${command.numberOfFloor} floor(s), ${command.numberOfRoomsPerFloor} room(s) per floor.';
}

/// This function is for booking the room for someone(guest)
/// Can't book the room that has been booked
String executeBookRoomCommand(BookRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final room = hotel.getRoom(number: command.roomNumber);

  if (room == null) {
    return 'The room number is incorrect';
  }

  switch (room.status) {
    case RoomStatus.ready:
      final keyCard = hotel.findAvailableKeyCardFor(room: room);

      if (keyCard == null) {
        return 'All key cards are in use';
      }

      keyCard.setupFor(
        room: room,
        guest: Guest(
          name: command.guestName,
          age: command.guestAge,
        ),
      );

      return 'Room ${room.number} is booked by ${command.guestName} with keycard number ${keyCard.number}.';

    case RoomStatus.using:
      return 'Cannot book room ${room.number} for ${command.guestName}, The room is currently booked by ${room.owner?.name ?? '-'}.';
  }
}

/// This function is for checing out the room
/// The key and guest must match If not, rejected.
String executeCheckoutRoomCommand(CheckoutRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final keyCard = hotel.getKeyCard(number: command.keyCardNumber);
  final room = keyCard?.room;

  if (keyCard == null || room == null || !keyCard.isUsing) {
    return 'The key card number is incorrect or not in use';
  }

  final keycardOwnerName = keyCard.owner?.name;
  final isCheckoutSuccess = hotel.checkout(
    keyCard: keyCard,
    guestName: command.guestName,
  );

  if (!isCheckoutSuccess) {
    return 'Only ${keycardOwnerName ?? '-'} can checkout with keycard number ${command.keyCardNumber}.';
  }

  return 'Room ${room.number} is checkout.';
}

/// This function is for getting a list of rooms that available to book
String executeListAvailableRoomsCommand(ListAvailableRoomsCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final availableRooms = hotel.findAvailableRooms;
  if (availableRooms.isEmpty) {
    return 'Hotel is filled';
  }

  return availableRooms.map((e) => e.number).join(', ');
}

/// This function is for getting a list of guests in the hotel
String executeListGuestCommand(ListGuestCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final guests = hotel.guests;

  if (guests.isEmpty) {
    return 'No any guest at the hotel for now';
  }

  return guests.map((e) => e.name).toSet().toList().join(', ');
}

/// This function is for getting a guest who owns this room
String executeGetGuestInRoomCommand(GetGuestInRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final room = hotel.getRoom(number: command.roomNumber);
  if (room == null) {
    return 'Romm number is invalid';
  }

  final owner = room.owner;
  if (owner == null) {
    return '${room.number} is not in use';
  }

  return owner.name;
}

/// This function is for getting a list of guests whose age matches the range
String executeListGuestByAgeCommand(ListGuestByAgeCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  bool Function(int, int)? test;

  switch (command.operator) {
    case '>':
      test = (p0, p1) => p0 > p1;
      break;

    case '>=':
      test = (p0, p1) => p0 >= p1;
      break;

    case '<':
      test = (p0, p1) => p0 < p1;
      break;

    case '<=':
      test = (p0, p1) => p0 <= p1;
      break;

    case '=':
      test = (p0, p1) => p0 == p1;
      break;

    case '!=':
      test = (p0, p1) => p0 != p1;
      break;

    default:
      break;
  }

  if (test == null) {
    return 'The operator is invalid';
  }

  final guests = hotel.guests.where((e) => test!(e.age, command.age)).toList();
  if (guests.isEmpty) {
    return 'No guest matches this range of age';
  }

  return guests.map((e) => e.name).toSet().join(', ');
}

/// This function is for getting a list of guests who book a room on this floor
String executeListGuestByFloorCommand(ListGuestByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final guestsName = hotel
      .findGuestsAtFloor(command.floor)
      .map((e) => e.name)
      .toSet()
      .toList();

  if (guestsName.isEmpty) {
    return 'No guests are on floor ${command.floor}';
  }

  return guestsName.join(', ');
}

/// This function is for checking out all rooms on this floor
String executeCheckoutGuestByFloorCommand(CheckoutGuestByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final keyCards = hotel.findUsingKeyCardsAtFloor(command.floor).toList();

  if (keyCards.isEmpty) {
    return 'No rooms are on floor ${command.floor} is in use';
  }

  final checkoutRoomNumbers =
      keyCards.map((e) => e.room?.number ?? '').join(', ');

  for (final keyCard in keyCards) {
    hotel.forceCheckout(keyCard: keyCard);
  }

  return 'Room $checkoutRoomNumbers are checkout.';
}

/// This function is for book all rooms on this floor
/// All rooms on this floor must be available if not, rejected
String executeBookRoomsByFloorCommand(BookRoomsByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final rooms = hotel.findRoomsAtFloor(command.floor);
  final isAllRoomAvailable = rooms.every((e) => e.status == RoomStatus.ready);

  if (!isAllRoomAvailable) {
    return 'Cannot book floor ${command.floor} for ${command.guestName}.';
  }

  final List<KeyCard> keyCards = [];
  for (final room in rooms) {
    final keyCard = hotel.findAvailableKeyCardFor(room: room);

    if (keyCard == null) {
      return 'All key cards are in use';
    }

    keyCard.setupFor(
      room: room,
      guest: Guest(
        name: command.guestName,
        age: command.guestAge,
      ),
    );

    keyCards.add(keyCard);
  }

  return 'Room ${keyCards.map((e) => e.room?.number ?? '').join(', ')} are booked with keycard number ${keyCards.map((e) => e.number).join(', ')}';
}
