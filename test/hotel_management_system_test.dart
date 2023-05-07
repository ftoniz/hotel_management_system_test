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
}
