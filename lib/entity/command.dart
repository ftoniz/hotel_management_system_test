/// This function using to cast the command string to class
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
      return CheckoutRoomCommand(rawParams: rawParams);

    case 'list_available_rooms':
      return ListAvailableRoomsCommand(rawParams: rawParams);

    case 'list_guest':
      return ListGuestCommand(rawParams: rawParams);

    case 'get_guest_in_room':
      return GetGuestInRoomCommand(rawParams: rawParams);

    case 'list_guest_by_age':
      return ListGuestByAgeCommand(rawParams: rawParams);

    case 'list_guest_by_floor':
      return ListGuestByFloorCommand(rawParams: rawParams);

    case 'checkout_guest_by_floor':
      return CheckoutGuestByFloorCommand(rawParams: rawParams);

    case 'book_by_floor':
      return BookRoomsByFloorCommand(rawParams: rawParams);

    default:
      return UnknownCommand(rawParams: rawParams);
  }
}

/// This class is the interface of the command class
abstract class Command {
  Command({
    required this.rawParams,
  });

  final List<String> rawParams;
  int get _requiredParamslength;

  bool get isValid => rawParams.length >= _requiredParamslength;
}

/// This is the unknown command class
/// The system has no need to do anything
class UnknownCommand extends Command {
  UnknownCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 0;
}

/// This is a command to execute to create the hote;
class CreateHotelCommand extends Command {
  CreateHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 2;

  int get numberOfFloor => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;

  int get numberOfRoomsPerFloor => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[1]) ?? 0
      : 0;
}

/// This is a command to execute to book a room for guests
class BookRoomCommand extends Command {
  BookRoomCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 3;

  String get roomNumber =>
      rawParams.length >= _requiredParamslength ? rawParams[0] : '';

  String get guestName =>
      rawParams.length >= _requiredParamslength ? rawParams[1] : '';

  int get guestAge => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[2]) ?? 0
      : 0;
}

/// This is a command to execute to checout a room
class CheckoutRoomCommand extends Command {
  CheckoutRoomCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 2;

  int get keyCardNumber => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;

  String get guestName =>
      rawParams.length >= _requiredParamslength ? rawParams[1] : '';
}

/// This is a command to execute to get a list of rooms that are available for booking
class ListAvailableRoomsCommand extends Command {
  ListAvailableRoomsCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 0;
}

/// This is a command to execute to get a list of guests in the hotel
class ListGuestCommand extends Command {
  ListGuestCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 0;
}

/// This is a command to execute to get a guest who owns the room
class GetGuestInRoomCommand extends Command {
  GetGuestInRoomCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 1;

  String get roomNumber =>
      rawParams.length >= _requiredParamslength ? rawParams[0] : '';
}

/// This is a command to execute to get a list of guest whose ages match the ranges
class ListGuestByAgeCommand extends Command {
  ListGuestByAgeCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 2;

  String get operator =>
      rawParams.length >= _requiredParamslength ? rawParams[0] : '';

  int get age => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[1]) ?? 0
      : 0;
}

/// This is a command to execute to get a list of guests who are on this floor
class ListGuestByFloorCommand extends Command {
  ListGuestByFloorCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 1;

  int get floor => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;
}

/// This is a command to execute to check out all rooms on this floor
class CheckoutGuestByFloorCommand extends Command {
  CheckoutGuestByFloorCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 1;

  int get floor => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;
}

/// This is a command to execute to book all rooms on this floor
class BookRoomsByFloorCommand extends Command {
  BookRoomsByFloorCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 3;

  int get floor => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;

  String get guestName =>
      rawParams.length >= _requiredParamslength ? rawParams[1] : '';

  int get guestAge => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[2]) ?? 0
      : 0;
}
