import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/resources/reusable_elevated_button.dart';
import 'package:skribbl_clone/view_models/create_room_view_model.dart';

class CreateRoomView extends StatelessWidget {
  const CreateRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateRoomViewModel viewModel = Get.put(CreateRoomViewModel());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Create Room",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: viewModel.playerNameController,
              decoration: const InputDecoration(
                hintText: "Player Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: viewModel.roomNameController,
              decoration: const InputDecoration(
                hintText: "Room Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => DropdownButton<int>(
                value: viewModel.selectedMaxRounds.value,
                hint: const Text("Select Max Rounds"),
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: viewModel.setMaxRounds,
                items: viewModel.rounds.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => DropdownButton<int>(
                value: viewModel.selectedRoomSize.value,
                hint: const Text("Select Room Size"),
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: viewModel.setRoomSize,
                items: viewModel.players.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            ReuseableElevatedbutton(
              onPressed: viewModel.createRoom,
              buttonName: "Create",
            ),
          ],
        ),
      ),
    );
  }
}
