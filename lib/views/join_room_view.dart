import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/resources/widgets/reusable_elevated_button.dart';
import 'package:skribbl_clone/utils/routes/route_names.dart';

class JoinRoomView extends StatelessWidget {
  JoinRoomView({super.key});

  final TextEditingController _playerNameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  void joinRoom() {
    if (_playerNameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty) {
      Map data = {
        'playerName': _playerNameController.text,
        'roomName': _roomNameController.text,
      };

      Get.toNamed(
        RouteNames.paintScreen,
        arguments: {"from": "joinRoom", 'data': data},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Join Room",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _playerNameController,
              decoration: const InputDecoration(
                hintText: "Player Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _roomNameController,
              decoration: const InputDecoration(
                hintText: "Room Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ReuseableElevatedbutton(
              onPressed: joinRoom,
              buttonName: "Join",
            ),
          ],
        ),
      ),
    );
  }
}
