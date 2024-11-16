import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/models/touch_points.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintViewModel extends GetxController {
  late IO.Socket socket;

  String screenFrom = Get.arguments["from"];

  Rx<Map> dataOfRoom = Rx<Map>({});
  Rx<Map> clientData = Rx<Map>({});
  Rx<List<TouchPoints>> points = Rx<List<TouchPoints>>([]);
  Rx<List<Widget>> listOfAlphabets = Rx<List<Widget>>([]);
  Rx<List<List>> messages = Rx<List<List>>([]);

  //paint brush options
  Rx<StrokeCap> strokeType = StrokeCap.round.obs;
  Rx<Color> selectedColor = Rx<Color>(Colors.black);
  RxDouble strokeWidth = 2.0.obs;
  RxDouble opacity = (1.0).obs;

  Timer? timer;
  RxInt start = 60.obs;
  RxInt guessedUserCounter = 0.obs;

  final messageTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    clientData.value = Get.arguments["data"];
    screenFrom = Get.arguments["from"];
    connectSocket(screenFrom);
  }

  void connectSocket(String screenFrom) {
    socket = IO.io("http://192.168.102.1:3000", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    if (screenFrom == "createRoom") {
      socket.emit("create-room", clientData.value);
    } else if (screenFrom == "joinRoom") {
      socket.emit("join-room", clientData.value);
    }

    socket.onConnect((_) {
      //updateRoom
      socket.on("updateRoom", (data) {
        dataOfRoom.value = data;
        if (data["isJoin"] != true) {
          getWord();
          startTimer();
        }
        update();
      });

      socket.on("points", (point) {
        if (point["details"] != null) {
          double dx = point['details']["dx"];
          double dy = point['details']["dy"];
          points.value.add(TouchPoints(
            paint: Paint()
              ..color = selectedColor.value.withOpacity(opacity.value)
              ..strokeWidth = strokeWidth.value
              ..isAntiAlias = true
              ..strokeCap = strokeType.value,
            points: Offset(dx, dy),
          ));
          // update();
        }
      });

      socket.on("color-change", (color) {
        int value = int.parse(color, radix: 16);
        selectedColor.value = Color(value);
      });

      socket.on("strokeWidth-change", (width) {
        strokeWidth.value = width;
      });

      socket.on("clear-canvas", (_) {
        points.value.clear();
      });

      socket.on("message", (data) {
        messages.value
            .add([data['playerName'], data['message'], data['isCorrectWord']]);
        if (data['isCorrectWord']) guessedUserCounter.value++;

        //change turn if all players have gussed correct word or time runs out
        if (guessedUserCounter.value ==
            dataOfRoom.value['players'].length - 1) {
          if (clientData.value["playerName"] ==
              dataOfRoom.value["turn"]["playerName"]) {
            socket.emit(
                "change-turn", {'roomName': dataOfRoom.value['roomName']});
          }
        }
      });

      socket.on("change-turn", (data) {
        String word = dataOfRoom.value['word'];
        Get.dialog(
          AlertDialog(
            content: Text("Word was $word"),
          ),
          barrierDismissible: false,
        );
        Future.delayed(const Duration(seconds: 3), () {
          dataOfRoom.value = data;
          getWord();
          guessedUserCounter.value = 0;
          start.value = 60;
          points.value.clear();
          timer?.cancel();
          startTimer();
          Get.back();
        });

        update();
      });
    });
  }

  void getWord() {
    String word = dataOfRoom.value['word'];
    listOfAlphabets.value = word.split("").map((char) {
      return Text(clientData.value["playerName"] ==
              dataOfRoom.value["turn"]["playerName"]
          ? char
          : "_");
    }).toList();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (start.value == 0) {
        socket.emit("change-turn", {'roomName': dataOfRoom.value['roomName']});
        timer?.cancel();
      } else {
        start.value--;
      }
    });
  }

  void changeColor(Color color) {
    selectedColor.value = color;
    String colorString = color.value.toRadixString(16);
    socket.emit("color-change", {
      'color': colorString,
      'roomName': dataOfRoom.value['roomName'],
    });
  }

  @override
  void onClose() {
    socket.dispose();
    timer?.cancel();
    super.onClose();
  }
}
