import 'dart:io';

import 'package:hotel_management_system/entity/command.dart';
import 'package:hotel_management_system/entity/guest.dart';
import 'package:hotel_management_system/entity/hotel.dart';
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
  } else if (command is CheckOutRoomCommand) {
    executeCheckoutRoomCommand(command);
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
      var keyCard =
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

void executeCheckoutRoomCommand(CheckOutRoomCommand command) {
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

  var canReturnKey = keyCard.canRetureKeyBy(command.guestName);
  if (!canReturnKey) {
    print(
      'Only ${keyCard.owner?.name ?? '-'} can checkout with keycard number ${keyCard.number}.',
    );
    return;
  }

  keyCard.returnKeyBy(command.guestName);

  print('Room ${room.number} is checkout.');
}
