import 'package:hotel_management_system/entity/command.dart';
import 'package:hotel_management_system/entity/hotel.dart';
import 'package:test/test.dart';

import '../bin/hotel_management_system.dart';

void main() {
  test('fake data test', () {
    final fakeInput = '''create_hotel 2 3
book 203 Thor 32
book 101 PeterParker 16
book 102 StephenStrange 36
book 201 TonyStark 48
book 202 TonyStark 48
book 203 TonyStark 48
list_available_rooms
checkout 4 TonyStark
book 103 TonyStark 48
book 101 Thanos 65
checkout 1 TonyStark
checkout 5 TonyStark
checkout 4 TonyStark
list_guest
get_guest_in_room 203
list_guest_by_age < 18
list_guest_by_floor 2
checkout_guest_by_floor 1
book_by_floor 1 TonyStark 48
book_by_floor 2 TonyStark 48''';

    final commands = getCommandsFromString(fakeInput);
    final hotel = Hotel();

    final results =
        commands.map((command) => command.execute(hotel: hotel)).join('\n');

    final expectOutput = '''Hotel created with 2 floor(s), 3 room(s) per floor.
Room 203 is booked by Thor with keycard number 1.
Room 101 is booked by PeterParker with keycard number 2.
Room 102 is booked by StephenStrange with keycard number 3.
Room 201 is booked by TonyStark with keycard number 4.
Room 202 is booked by TonyStark with keycard number 5.
Cannot book room 203 for TonyStark, The room is currently booked by Thor.
103
Room 201 is checkout.
Room 103 is booked by TonyStark with keycard number 4.
Cannot book room 101 for Thanos, The room is currently booked by PeterParker.
Only Thor can checkout with keycard number 1.
Room 202 is checkout.
Room 103 is checkout.
Thor, PeterParker, StephenStrange
Thor
PeterParker
Thor
Room 101, 102 are checkout.
Room 101, 102, 103 are booked with keycard number 2, 3, 4
Cannot book floor 2 for TonyStark.''';

    expect(results, expectOutput);
  });

  test('setup and reset hotel smoke test', () {
    final hotel = Hotel();
    expect(hotel.rooms.length, 0);
    expect(hotel.keyCards.length, 0);
    expect(hotel.guests.length, 0);
    expect(hotel.isAllowToSetup, true);
    expect(hotel.isReadyToUse, false);

    hotel.setup(
      numberOfFloor: 2,
      numberOfRoomsPerFloor: 3,
    );

    expect(hotel.rooms.length, 6);
    expect(hotel.keyCards.length, 6);
    expect(hotel.guests.length, 0);
    expect(hotel.isAllowToSetup, false);
    expect(hotel.isReadyToUse, true);

    hotel.setup(
      numberOfFloor: 4,
      numberOfRoomsPerFloor: 4,
    );

    expect(hotel.rooms.length, 6);
    expect(hotel.keyCards.length, 6);
    expect(hotel.guests.length, 0);
    expect(hotel.isAllowToSetup, false);
    expect(hotel.isReadyToUse, true);

    hotel.reset();

    expect(hotel.rooms.length, 0);
    expect(hotel.keyCards.length, 0);
    expect(hotel.guests.length, 0);
    expect(hotel.isAllowToSetup, true);
    expect(hotel.isReadyToUse, false);

    hotel.setup(
      numberOfFloor: 4,
      numberOfRoomsPerFloor: 4,
    );

    expect(hotel.rooms.length, 16);
    expect(hotel.keyCards.length, 16);
    expect(hotel.guests.length, 0);
    expect(hotel.isAllowToSetup, false);
    expect(hotel.isReadyToUse, true);

    hotel.reset();
    SetupHotelCommand(rawParams: [
      '2',
      '3',
    ]).execute(hotel: hotel);

    expect(hotel.rooms.length, 6);
    expect(hotel.keyCards.length, 6);
    expect(hotel.guests.length, 0);
    expect(hotel.isAllowToSetup, false);
    expect(hotel.isReadyToUse, true);
  });

  test('guest book and checkout smoke test', () {
    final hotel = Hotel();

    hotel.setup(
      numberOfFloor: 2,
      numberOfRoomsPerFloor: 3,
    );

    expect(hotel.guests.length, 0);
    BookRoomHotelCommand(rawParams: [
      '101',
      'Peter',
      '20',
    ]).execute(hotel: hotel);

    expect(hotel.guests.length, 1);
    expect(hotel.guests[0].name, 'Peter');
    expect(hotel.guests[0].age, 20);

    final room101 = hotel.getRoom(number: '101');
    expect(room101?.owner?.name, 'Peter');
    expect(room101?.owner?.age, 20);

    final keyCard1 = hotel.getKeyCard(number: 1);
    expect(keyCard1?.room?.number, '101');
    expect(keyCard1?.owner?.name, 'Peter');
    expect(keyCard1?.owner?.age, 20);

    BookRoomHotelCommand(rawParams: [
      '102',
      'Peter',
      '20',
    ]).execute(hotel: hotel);

    expect(hotel.guests.length, 2);
    final room102 = hotel.getRoom(number: '102');
    expect(room102?.owner?.name, 'Peter');
    expect(room102?.owner?.age, 20);

    final keyCard2 = hotel.getKeyCard(number: 2);
    expect(keyCard2?.room?.number, '102');
    expect(keyCard2?.owner?.name, 'Peter');
    expect(keyCard2?.owner?.age, 20);

    BookRoomHotelCommand(rawParams: [
      '103',
      'Tony',
      '40',
    ]).execute(hotel: hotel);

    expect(hotel.guests.length, 3);
    final room103 = hotel.getRoom(number: '103');
    expect(room103?.owner?.name, 'Tony');
    expect(room103?.owner?.age, 40);

    final keyCard3 = hotel.getKeyCard(number: 3);
    expect(keyCard3?.room?.number, '103');
    expect(keyCard3?.owner?.name, 'Tony');
    expect(keyCard3?.owner?.age, 40);

    CheckoutRoomHotelCommand(rawParams: [
      '2',
      'Peter',
    ]).execute(hotel: hotel);

    expect(hotel.guests.length, 2);
    expect(room102?.owner, null);
    expect(keyCard2?.room, null);
    expect(keyCard2?.owner, null);

    CheckoutRoomHotelCommand(rawParams: [
      '1',
      'Peter',
    ]).execute(hotel: hotel);

    expect(hotel.guests.length, 1);
    expect(room101?.owner, null);
    expect(keyCard1?.room, null);
    expect(keyCard1?.owner, null);
  });

  test('getting list of something (hotel) smoke test', () {
    final hotel = Hotel();

    hotel.setup(
      numberOfFloor: 2,
      numberOfRoomsPerFloor: 3,
    );

    BookRoomHotelCommand(rawParams: ['101', 'Tony', '10'])
        .execute(hotel: hotel);
    BookRoomHotelCommand(rawParams: ['102', 'Peter', '20'])
        .execute(hotel: hotel);
    BookRoomHotelCommand(rawParams: ['103', 'Parker', '30'])
        .execute(hotel: hotel);
    BookRoomHotelCommand(rawParams: ['201', 'Stephen', '40'])
        .execute(hotel: hotel);

    expect(
      hotel.findAvailableRooms.map((e) => e.number),
      ['202', '203'],
    );

    expect(
      hotel.findGuestsAtFloor(1).map((e) => e.name),
      ['Tony', 'Peter', 'Parker'],
    );

    expect(
      hotel.findGuestsAtFloor(2).map((e) => e.name),
      ['Stephen'],
    );

    expect(
      hotel.findGuestsAtAge(operator: '>', age: 20).map((e) => e.name),
      ['Parker', 'Stephen'],
    );

    expect(
      hotel.findGuestsAtAge(operator: '>=', age: 20).map((e) => e.name),
      ['Peter', 'Parker', 'Stephen'],
    );

    expect(
      hotel.findGuestsAtAge(operator: '<', age: 20).map((e) => e.name),
      ['Tony'],
    );

    expect(
      hotel.findGuestsAtAge(operator: '<=', age: 20).map((e) => e.name),
      ['Tony', 'Peter'],
    );

    expect(
      hotel.findGuestsAtAge(operator: '=', age: 20).map((e) => e.name),
      ['Peter'],
    );

    expect(
      hotel.findKeyCardsAtFloor(1).map((e) => e.number),
      [1, 2, 3],
    );

    expect(
      hotel.findKeyCardsAtFloor(2).map((e) => e.number),
      [4],
    );
  });

  test('book and checkout floor smoke test', () {
    final hotel = Hotel();

    hotel.setup(
      numberOfFloor: 2,
      numberOfRoomsPerFloor: 3,
    );

    BookRoomsByFloorHotelCommand(rawParams: ['1', 'Tony', '20'])
        .execute(hotel: hotel);
    BookRoomsByFloorHotelCommand(rawParams: ['2', 'Stark', '40'])
        .execute(hotel: hotel);

    expect(
      hotel.findGuestsAtFloor(1).map((e) => e.name),
      ['Tony', 'Tony', 'Tony'],
    );

    expect(
      hotel.findGuestsAtFloor(2).map((e) => e.name),
      ['Stark', 'Stark', 'Stark'],
    );

    CheckoutGuestByFloorHotelCommand(rawParams: ['1']).execute(hotel: hotel);
    expect(
      hotel.findGuestsAtFloor(1).map((e) => e.name),
      [],
    );

    BookRoomHotelCommand(rawParams: ['101', 'Parker', '30'])
        .execute(hotel: hotel);
    expect(
      hotel.findGuestsAtFloor(1).map((e) => e.name),
      ['Parker'],
    );

    BookRoomsByFloorHotelCommand(rawParams: ['1', 'Tony', '20'])
        .execute(hotel: hotel);

    expect(
      hotel.findGuestsAtFloor(1).map((e) => e.name),
      ['Parker'],
    );

    CheckoutGuestByFloorHotelCommand(rawParams: ['1']).execute(hotel: hotel);
    expect(
      hotel.findGuestsAtFloor(1).map((e) => e.name),
      [],
    );
  });
}
