import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/utils/routes/route_names.dart';

class CreateRoomViewModel extends GetxController {
  final TextEditingController playerNameController = TextEditingController();
  final TextEditingController roomNameController = TextEditingController();

  final List<int> rounds = [2, 5, 10, 15];
  final List<int> players = [2, 3, 4, 5, 6, 7, 8];

  Rx<int?> selectedMaxRounds = Rx<int?>(null);
  Rx<int?> selectedRoomSize = Rx<int?>(null);

  void setMaxRounds(int? value) {
    selectedMaxRounds.value = value;
  }

  void setRoomSize(int? value) {
    selectedRoomSize.value = value;
  }

  void createRoom() {
    if (playerNameController.text.isNotEmpty &&
        roomNameController.text.isNotEmpty &&
        selectedRoomSize.value != null &&
        selectedMaxRounds.value != null) {
      Map<String, dynamic> data = {
        'playerName': playerNameController.text,
        'roomName': roomNameController.text,
        'occupancy': selectedRoomSize.value,
        'maxRounds': selectedMaxRounds.value,
      };

      Get.toNamed(
        RouteNames.paintScreen,
        arguments: {"from": "createRoom", "data": data},
      );
    }
  }

  @override
  void onClose() {
    playerNameController.dispose();
    roomNameController.dispose();
    super.onClose();
  }
}
