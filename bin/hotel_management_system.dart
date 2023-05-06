import 'dart:io';

import 'package:hotel_management_system/entity/command.dart';
import 'package:hotel_management_system/entity/guest.dart';
import 'package:hotel_management_system/entity/hotel.dart';
import 'package:hotel_management_system/entity/key_card.dart';
import 'package:hotel_management_system/entity/room.dart';
import 'package:hotel_management_system/extensions/list_extensions.dart';

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

String executeBookRoomCommand(BookRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final room =
      hotel.rooms.tryFirstWhere((room) => room.number == command.roomNumber);

  if (room == null) {
    return 'The room number is incorrect';
  }

  switch (room.status) {
    case RoomStatus.ready:
      final keyCard =
          hotel.keyCards.tryFirstWhere((e) => e.canSetupFor(room: room));

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

String executeCheckoutRoomCommand(CheckoutRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final keyCard = hotel.keyCards.tryFirstWhere(
    (key) => key.number == command.keyCardNumber && key.isUsing,
  );

  final room = keyCard?.room;

  if (keyCard == null || room == null) {
    return 'The key card number is incorrect or not in use';
  }

  final canReturnKey = keyCard.canRetureKeyBy(command.guestName);
  if (!canReturnKey) {
    return 'Only ${keyCard.owner?.name ?? '-'} can checkout with keycard number ${keyCard.number}.';
  }

  keyCard.returnKeyBy(command.guestName);
  return 'Room ${room.number} is checkout.';
}

String executeListAvailableRoomsCommand(ListAvailableRoomsCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final availableRooms = hotel.rooms.where((e) => e.status == RoomStatus.ready);
  if (availableRooms.isEmpty) {
    return 'Hotel is filled';
  }

  return availableRooms.map((e) => e.number).join(' ');
}

String executeListGuestCommand(ListGuestCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final guests = hotel.keyCards
      .where((e) => e.isUsing)
      .map((e) => e.owner?.name ?? '')
      .toSet()
      .toList();

  if (guests.isEmpty) {
    return 'No any guest at the hotel for now';
  }

  return guests.join(', ');
}

String executeGetGuestInRoomCommand(GetGuestInRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final room = hotel.rooms.tryFirstWhere((e) => e.number == command.roomNumber);
  if (room == null) {
    return 'Romm number is invalid';
  }

  final owner = room.owner;
  if (owner == null) {
    return '${room.number} is not in use';
  }

  return owner.name;
}

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

String executeListGuestByFloorCommand(ListGuestByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final guests = hotel.rooms
      .where((e) => e.floor == command.floor && e.status == RoomStatus.using)
      .map((e) => e.owner?.name ?? '')
      .where((e) => e != '')
      .toSet()
      .toList();

  if (guests.isEmpty) {
    return 'No guests are on floor ${command.floor}';
  }

  return guests.join(', ');
}

String executeCheckoutGuestByFloorCommand(CheckoutGuestByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final keyCards = hotel.keyCards
      .where((e) => e.isUsing && e.room?.floor == command.floor)
      .toList();

  if (keyCards.isEmpty) {
    return 'No rooms are on floor ${command.floor} is in use';
  }

  final checkoutRoomNumbers =
      keyCards.map((e) => e.room?.number ?? '').join(', ');

  for (final keyCard in keyCards) {
    keyCard.forceRetureKey();
  }

  return 'Room $checkoutRoomNumbers are checkout.';
}

String executeBookRoomsByFloorCommand(BookRoomsByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    return 'The hotel had not created';
  }

  final rooms = hotel.rooms.where((e) => e.floor == command.floor).toList();
  final isAllRoomAvailable = rooms.every((e) => e.status == RoomStatus.ready);

  if (!isAllRoomAvailable) {
    return 'Cannot book floor ${command.floor} for ${command.guestName}.';
  }

  final List<KeyCard> keyCards = [];
  for (final room in rooms) {
    final keyCard =
        hotel.keyCards.tryFirstWhere((e) => e.canSetupFor(room: room));

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
