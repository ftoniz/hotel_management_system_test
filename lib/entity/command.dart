import 'package:hotel_management_system/entity/hotel.dart';
import 'package:hotel_management_system/entity/room.dart';

import 'guest.dart';
import 'key_card.dart';

/// This function using to cast the command string to class
HotelCommand generateCommand({required String command}) {
  var rawParams = command.split(' ');
  if (rawParams.isEmpty) {
    return UnknownHotelCommand(rawParams: rawParams);
  }

  var name = rawParams[0];
  rawParams = rawParams.sublist(1);

  switch (name) {
    case 'create_hotel':
      return CreateHotelHotelCommand(rawParams: rawParams);

    case 'book':
      return BookRoomHotelCommand(rawParams: rawParams);

    case 'checkout':
      return CheckoutRoomHotelCommand(rawParams: rawParams);

    case 'list_available_rooms':
      return ListAvailableRoomsHotelCommand(rawParams: rawParams);

    case 'list_guest':
      return ListGuestHotelCommand(rawParams: rawParams);

    case 'get_guest_in_room':
      return GetGuestInRoomHotelCommand(rawParams: rawParams);

    case 'list_guest_by_age':
      return ListGuestByAgeHotelCommand(rawParams: rawParams);

    case 'list_guest_by_floor':
      return ListGuestByFloorHotelCommand(rawParams: rawParams);

    case 'checkout_guest_by_floor':
      return CheckoutGuestByFloorHotelCommand(rawParams: rawParams);

    case 'book_by_floor':
      return BookRoomsByFloorHotelCommand(rawParams: rawParams);

    default:
      return UnknownHotelCommand(rawParams: rawParams);
  }
}

/// This class is the interface of the command class
abstract class HotelCommand {
  HotelCommand({
    required this.rawParams,
  });

  final List<String> rawParams;
  int get _requiredParamslength;

  bool get isValid => rawParams.length >= _requiredParamslength;

  String execute({required Hotel hotel});
}

/// This is the unknown command class
/// The system has no need to do anything
class UnknownHotelCommand extends HotelCommand {
  UnknownHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 0;

  @override
  String execute({required Hotel hotel}) {
    return '';
  }
}

/// This is a command to execute to create the hote;
class CreateHotelHotelCommand extends HotelCommand {
  CreateHotelHotelCommand({
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

  /// This execution function is for setting floors and rooms for the hotel
  /// It can execute only one time
  /// On other times will be rejected
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isAllowToSetup) {
      return 'The hotel had already setup';
    }

    hotel.setup(
      numberOfFloor: numberOfFloor,
      numberOfRoomsPerFloor: numberOfRoomsPerFloor,
    );

    return 'Hotel created with $numberOfFloor floor(s), $numberOfRoomsPerFloor room(s) per floor.';
  }
}

/// This is a command to execute to book a room for guests
class BookRoomHotelCommand extends HotelCommand {
  BookRoomHotelCommand({
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

  /// This execution function is for booking the room for someone(guest)
  /// Can't book the room that has been booked
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    final room = hotel.getRoom(number: roomNumber);

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
            name: guestName,
            age: guestAge,
          ),
        );

        return 'Room ${room.number} is booked by $guestName with keycard number ${keyCard.number}.';

      case RoomStatus.using:
        return 'Cannot book room ${room.number} for $guestName, The room is currently booked by ${room.owner?.name ?? '-'}.';
    }
  }
}

/// This is a command to execute to checout a room
class CheckoutRoomHotelCommand extends HotelCommand {
  CheckoutRoomHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 2;

  int get keyCardNumber => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;

  String get guestName =>
      rawParams.length >= _requiredParamslength ? rawParams[1] : '';

  /// This execution function is for checing out the room
  /// The key and guest must match If not, rejected.
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    final keyCard = hotel.getKeyCard(number: keyCardNumber);
    final room = keyCard?.room;

    if (keyCard == null || room == null || !keyCard.isUsing) {
      return 'The key card number is incorrect or not in use';
    }

    final keycardOwnerName = keyCard.owner?.name;
    final isCheckoutSuccess = hotel.checkout(
      keyCard: keyCard,
      guestName: guestName,
    );

    if (!isCheckoutSuccess) {
      return 'Only ${keycardOwnerName ?? '-'} can checkout with keycard number $keyCardNumber.';
    }

    return 'Room ${room.number} is checkout.';
  }
}

/// This is a command to execute to get a list of rooms that are available for booking
class ListAvailableRoomsHotelCommand extends HotelCommand {
  ListAvailableRoomsHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 0;

  /// This execution function is for getting a list of rooms that available to book
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    final availableRooms = hotel.findAvailableRooms;
    if (availableRooms.isEmpty) {
      return 'Hotel is filled';
    }

    return availableRooms.map((e) => e.number).join(', ');
  }
}

/// This is a command to execute to get a list of guests in the hotel
class ListGuestHotelCommand extends HotelCommand {
  ListGuestHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 0;

  /// This execution function is for getting a list of guests in the hotel
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    final guests = hotel.guests;

    if (guests.isEmpty) {
      return 'No any guest at the hotel for now';
    }

    return guests.map((e) => e.name).toSet().toList().join(', ');
  }
}

/// This is a command to execute to get a guest who owns the room
class GetGuestInRoomHotelCommand extends HotelCommand {
  GetGuestInRoomHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 1;

  String get roomNumber =>
      rawParams.length >= _requiredParamslength ? rawParams[0] : '';

  /// This execution function is for getting a guest who owns this room
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    final room = hotel.getRoom(number: roomNumber);
    if (room == null) {
      return 'Romm number is invalid';
    }

    final owner = room.owner;
    if (owner == null) {
      return '${room.number} is not in use';
    }

    return owner.name;
  }
}

/// This is a command to execute to get a list of guest whose ages match the ranges
class ListGuestByAgeHotelCommand extends HotelCommand {
  ListGuestByAgeHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 2;

  String get operator =>
      rawParams.length >= _requiredParamslength ? rawParams[0] : '';

  int get age => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[1]) ?? 0
      : 0;

  /// This execution function is for getting a list of guests whose age matches the range
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    bool Function(int, int)? test;

    switch (operator) {
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

    final guests = hotel.guests.where((e) => test!(e.age, age)).toList();
    if (guests.isEmpty) {
      return 'No guest matches this range of age';
    }

    return guests.map((e) => e.name).toSet().join(', ');
  }
}

/// This is a command to execute to get a list of guests who are on this floor
class ListGuestByFloorHotelCommand extends HotelCommand {
  ListGuestByFloorHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 1;

  int get floor => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;

  /// This execution function is for getting a list of guests who book a room on this floor
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    final guestsName =
        hotel.findGuestsAtFloor(floor).map((e) => e.name).toSet().toList();

    if (guestsName.isEmpty) {
      return 'No guests are on floor $floor';
    }

    return guestsName.join(', ');
  }
}

/// This is a command to execute to check out all rooms on this floor
class CheckoutGuestByFloorHotelCommand extends HotelCommand {
  CheckoutGuestByFloorHotelCommand({
    required super.rawParams,
  });

  @override
  int get _requiredParamslength => 1;

  int get floor => rawParams.length >= _requiredParamslength
      ? int.tryParse(rawParams[0]) ?? 0
      : 0;

  /// This execution function is for checking out all rooms on this floor
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    final keyCards = hotel.findUsingKeyCardsAtFloor(floor).toList();

    if (keyCards.isEmpty) {
      return 'No rooms are on floor $floor is in use';
    }

    final checkoutRoomNumbers =
        keyCards.map((e) => e.room?.number ?? '').join(', ');

    for (final keyCard in keyCards) {
      hotel.forceCheckout(keyCard: keyCard);
    }

    return 'Room $checkoutRoomNumbers are checkout.';
  }
}

/// This is a command to execute to book all rooms on this floor
class BookRoomsByFloorHotelCommand extends HotelCommand {
  BookRoomsByFloorHotelCommand({
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

  /// This execution function is for book all rooms on this floor
  /// All rooms on this floor must be available if not, rejected
  /// Give the log after finished as a return value
  @override
  String execute({required Hotel hotel}) {
    if (!hotel.isReadyToUse) {
      return 'The hotel had not ready';
    }

    final rooms = hotel.findRoomsAtFloor(floor);
    final isAllRoomAvailable = rooms.every((e) => e.status == RoomStatus.ready);

    if (!isAllRoomAvailable) {
      return 'Cannot book floor $floor for $guestName.';
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
          name: guestName,
          age: guestAge,
        ),
      );

      keyCards.add(keyCard);
    }

    return 'Room ${keyCards.map((e) => e.room?.number ?? '').join(', ')} are booked with keycard number ${keyCards.map((e) => e.number).join(', ')}';
  }
}
