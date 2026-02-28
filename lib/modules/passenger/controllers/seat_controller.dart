// lib/modules/passenger/controllers/seat_controller.dart

import 'package:get/get.dart';

import '../../../data/models/ticket/seat_model.dart';

class SeatController extends GetxController {
  static SeatController get instance => Get.find();

  // Observables
  final _seats = <SeatModel>[].obs;
  final _selectedSeats = <SeatModel>[].obs;

  // Getters
  List<SeatModel> get seats => _seats;
  List<SeatModel> get selectedSeats => _selectedSeats;

  // Handle real-time seat updates from socket
  void handleSeatUpdate(Map<String, dynamic> data) {
    final String tripId = data['tripId'];
    final int seatNumber = data['seatNumber'];
    final String status = data['status'];
    final DateTime? lockedUntil = data['lockedUntil'] != null
        ? DateTime.parse(data['lockedUntil'])
        : null;

    // Update seat in the list
    final index = _seats.indexWhere((seat) =>
    seat.tripId == tripId && seat.number == seatNumber.toString());

    if (index != -1) {
      final updatedSeat = _seats[index].copyWith(
        status: status,
        lockedUntil: lockedUntil,
      );
      _seats[index] = updatedSeat;
      _seats.refresh();

      // If this seat was selected and is now locked/booked, remove from selection
      if (_selectedSeats.contains(updatedSeat) &&
          (status == 'locked' || status == 'booked')) {
        _selectedSeats.remove(updatedSeat);
      }
    }
  }

  // Set seats list
  void setSeats(List<SeatModel> seats) {
    _seats.value = seats;
  }

  // Select/deselect seat
  void toggleSeatSelection(SeatModel seat) {
    if (_selectedSeats.contains(seat)) {
      _selectedSeats.remove(seat);
    } else {
      _selectedSeats.add(seat);
    }
  }

  // Clear selections
  void clearSelections() {
    _selectedSeats.clear();
  }
}