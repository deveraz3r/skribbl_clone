import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/resources/widgets/reusable_elevated_button.dart';
import 'package:skribbl_clone/utils/routes/route_names.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.sizeOf(context).height;
    final double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Create/Join room to Play",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReuseableElevatedbutton(
                width: width * 0.4,
                onPressed: () => Get.toNamed(RouteNames.createRoom),
                buttonName: "Create Room",
              ),
              const SizedBox(width: 10),
              ReuseableElevatedbutton(
                width: width * 0.4,
                onPressed: () => Get.toNamed(RouteNames.joinRoom),
                buttonName: ("Join Room"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
