import 'dart:io';

import 'package:hotel_management_system/entity/command.dart';
import 'package:hotel_management_system/entity/hotel.dart';

void main(List<String> arguments) {
  runCommands();
}

void runCommands() async {
  final fileName = 'input.txt';
  final fileData = await getStringFromFileName(fileName: fileName);
  final commands = getCommandsFromString(fileData);

  final results = commands
      .map((command) => command.execute(hotel: Hotel.instance))
      .join('\n');
  print(results);
}

Future<String> getStringFromFileName({
  required String fileName,
}) async =>
    await File(fileName).readAsString();

List<HotelCommand> getCommandsFromString(
  String input,
) =>
    input
        .split('\n')
        .map((command) => generateCommand(command: command))
        .where((command) => command is! UnknownHotelCommand && command.isValid)
        .toList();
