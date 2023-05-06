Command generateCommand({required String command}) {
  var rawParams = command.split(' ');
  if (rawParams.isEmpty) {
    return UnknownCommand(rawParams: rawParams);
  }

  var name = rawParams[0];
  rawParams = rawParams.sublist(1);

  switch (name) {
    case 'create_hotel':
      return CreateHotelCommand(rawParams: rawParams);

    case 'book':
      return BookRoomCommand(rawParams: rawParams);

    case 'checkout':
      return CheckOutRoomCommand(rawParams: rawParams);

    case 'list_available_rooms':
      return ListAvailableRoomsCommand(rawParams: rawParams);

    default:
      return UnknownCommand(rawParams: rawParams);
  }
}

abstract class Command {
  Command({
    required this.rawParams,
  });

  final List<String> rawParams;
  int get requiredParamslength;

  bool get isValid => rawParams.length >= requiredParamslength;
}

class UnknownCommand extends Command {
  UnknownCommand({
    required super.rawParams,
  });

  @override
  int get requiredParamslength => 0;
}

class CreateHotelCommand extends Command {
  CreateHotelCommand({
    required super.rawParams,
  });

  @override
  int get requiredParamslength => 2;

  int get numberOfFloor => rawParams.length >= requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;

  int get numberOfRoomsPerFloor => rawParams.length >= requiredParamslength
      ? int.tryParse(rawParams[1]) ?? 0
      : 0;
}

class BookRoomCommand extends Command {
  BookRoomCommand({
    required super.rawParams,
  });

  @override
  int get requiredParamslength => 3;

  String get roomNumber =>
      rawParams.length >= requiredParamslength ? rawParams[0] : '';

  String get guestName =>
      rawParams.length >= requiredParamslength ? rawParams[1] : '';

  int get guestAge => rawParams.length >= requiredParamslength
      ? int.tryParse(rawParams[2]) ?? 0
      : 0;
}

class CheckOutRoomCommand extends Command {
  CheckOutRoomCommand({
    required super.rawParams,
  });

  @override
  int get requiredParamslength => 2;

  int get keyCardNumber => rawParams.length >= requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;

  String get guestName =>
      rawParams.length >= requiredParamslength ? rawParams[1] : '';
}

class ListAvailableRoomsCommand extends Command {
  ListAvailableRoomsCommand({
    required super.rawParams,
  });

  @override
  int get requiredParamslength => 0;
}
