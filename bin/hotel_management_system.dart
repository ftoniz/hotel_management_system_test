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
  final commands = await getCommandsFromFileName(fileName: fileName);

  for (final command in commands) {
    executeCommand(command);
  }
}

Future<List<Command>> getCommandsFromFileName({
  required String fileName,
}) async {
  final input = await File(fileName).readAsString();
  return input
      .split('\n')
      .map((command) => generateCommand(command: command))
      .where((command) => command is! UnknownCommand && command.isValid)
      .toList();
}

void executeCommand(Command command) {
  if (command is CreateHotelCommand) {
    executeCreateHotelComamnd(command);
  } else if (command is BookRoomCommand) {
    executeBookRoomCommand(command);
  } else if (command is CheckoutRoomCommand) {
    executeCheckoutRoomCommand(command);
  } else if (command is ListAvailableRoomsCommand) {
    executeListAvailableRoomsCommand(command);
  } else if (command is ListGuestCommand) {
    executeListGuestCommand(command);
  } else if (command is GetGuestInRoomCommand) {
    executeGetGuestInRoomCommand(command);
  } else if (command is ListGuestByAgeCommand) {
    executeListGuestByAgeCommand(command);
  } else if (command is ListGuestByFloorCommand) {
    executeListGuestByFloorCommand(command);
  } else if (command is CheckoutGuestByFloorCommand) {
    executeCheckoutGuestByFloorCommand(command);
  } else if (command is BookRoomsByFloorCommand) {
    executeBookRoomsByFloorCommand(command);
  }
}

void executeCreateHotelComamnd(CreateHotelCommand command) {
  if (_hotel != null) {
    print('The hotel had already created');
    return;
  }

  _hotel = Hotel(
    floor: command.numberOfFloor,
    numberOfRoomsPerFloor: command.numberOfRoomsPerFloor,
  );

  print(
    'Hotel created with ${command.numberOfFloor} floor(s), ${command.numberOfRoomsPerFloor} room(s) per floor.',
  );
}

void executeBookRoomCommand(BookRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
  }

  final room =
      hotel.rooms.tryFirstWhere((room) => room.number == command.roomNumber);

  if (room == null) {
    print('The room number is incorrect');
    return;
  }

  switch (room.status) {
    case RoomStatus.ready:
      final keyCard =
          hotel.keyCards.tryFirstWhere((e) => e.canSetupFor(room: room));

      if (keyCard == null) {
        print('All key cards are in use');
        return;
      }

      keyCard.setupFor(
        room: room,
        guest: Guest(
          name: command.guestName,
          age: command.guestAge,
        ),
      );

      print(
        'Room ${room.number} is booked by ${command.guestName} with keycard number ${keyCard.number}.',
      );

      return;

    case RoomStatus.using:
      print(
        'Cannot book room ${room.number} for ${command.guestName}, The room is currently booked by ${room.owner?.name ?? '-'}.',
      );
      return;
  }
}

void executeCheckoutRoomCommand(CheckoutRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
  }

  final keyCard = hotel.keyCards.tryFirstWhere(
    (key) => key.number == command.keyCardNumber && key.isUsing,
  );

  final room = keyCard?.room;

  if (keyCard == null || room == null) {
    print('The key card number is incorrect or not in use');
    return;
  }

  final canReturnKey = keyCard.canRetureKeyBy(command.guestName);
  if (!canReturnKey) {
    print(
      'Only ${keyCard.owner?.name ?? '-'} can checkout with keycard number ${keyCard.number}.',
    );
    return;
  }

  keyCard.returnKeyBy(command.guestName);

  print('Room ${room.number} is checkout.');
}

void executeListAvailableRoomsCommand(ListAvailableRoomsCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
  }

  final availableRooms = hotel.rooms.where((e) => e.status == RoomStatus.ready);
  if (availableRooms.isEmpty) {
    print('Hotel is filled');
    return;
  }

  print(availableRooms.map((e) => e.number).join(' '));
}

void executeListGuestCommand(ListGuestCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
  }

  final guests = hotel.keyCards
      .where((e) => e.isUsing)
      .map((e) => e.owner?.name ?? '')
      .toSet()
      .toList();

  if (guests.isEmpty) {
    print('No any guest at the hotel for now');
    return;
  }

  print(guests.join(', '));
}

void executeGetGuestInRoomCommand(GetGuestInRoomCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
  }

  final room = hotel.rooms.tryFirstWhere((e) => e.number == command.roomNumber);
  if (room == null) {
    print('Romm number is invalid');
    return;
  }

  final owner = room.owner;
  if (owner == null) {
    print('${room.number} is not in use');
    return;
  }

  print(owner.name);
}

void executeListGuestByAgeCommand(ListGuestByAgeCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
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
    print('The operator is invalid');
    return;
  }

  final guests = hotel.guests.where((e) => test!(e.age, command.age)).toList();
  if (guests.isEmpty) {
    print('No guest matches this range of age');
    return;
  }

  print(guests.map((e) => e.name).toSet().join(', '));
}

void executeListGuestByFloorCommand(ListGuestByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
  }

  final guests = hotel.rooms
      .where((e) => e.floor == command.floor && e.status == RoomStatus.using)
      .map((e) => e.owner?.name ?? '')
      .where((e) => e != '')
      .toSet()
      .toList();

  if (guests.isEmpty) {
    print('No guests are on floor ${command.floor}');
    return;
  }

  print(guests.join(', '));
}

void executeCheckoutGuestByFloorCommand(CheckoutGuestByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
  }

  final keyCards = hotel.keyCards
      .where((e) => e.isUsing && e.room?.floor == command.floor)
      .toList();

  if (keyCards.isEmpty) {
    print('No rooms are on floor ${command.floor} is in use');
    return;
  }

  final checkoutRoomNumbers =
      keyCards.map((e) => e.room?.number ?? '').join(', ');

  for (final keyCard in keyCards) {
    keyCard.forceRetureKey();
  }

  print(
    'Room $checkoutRoomNumbers are checkout.',
  );
}

void executeBookRoomsByFloorCommand(BookRoomsByFloorCommand command) {
  final hotel = _hotel;
  if (hotel == null) {
    print('The hotel had not created');
    return;
  }

  final rooms = hotel.rooms.where((e) => e.floor == command.floor).toList();
  final isAllRoomAvailable = rooms.every((e) => e.status == RoomStatus.ready);

  if (!isAllRoomAvailable) {
    print('Cannot book floor ${command.floor} for ${command.guestName}.');
    return;
  }

  final List<KeyCard> keyCards = [];
  for (final room in rooms) {
    final keyCard =
        hotel.keyCards.tryFirstWhere((e) => e.canSetupFor(room: room));

    if (keyCard == null) {
      print('All key cards are in use');
      return;
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

  print(
    'Room ${keyCards.map((e) => e.room?.number ?? '').join(', ')} are booked with keycard number ${keyCards.map((e) => e.number).join(', ')}',
  );
}
