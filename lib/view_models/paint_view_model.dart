import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/models/touch_points.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintViewModel extends GetxController {
  var dataOfRoom = {}.obs;
  var points = <TouchPoints>[].obs;
  String screenFrom = "";

  //paint brush
  var strokeType = StrokeCap.round.obs;
  var selectedColor = Colors.black.obs;
  var opacity = 1.0.obs;
  var strokeWidth = 2.0.obs;

  //socket variable
  late IO.Socket _socket;

  void connect(String from, Map data) {
    screenFrom = from;
    dataOfRoom.value = data;

    _socket = IO.io("http://192.168.102.1:3000", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    if (screenFrom == "createRoom") {
      _socket.emit("create-room", dataOfRoom);
    } else if (screenFrom == "joinRoom") {
      _socket.emit("join-room", dataOfRoom);
    }

    _socket.onConnect((_) {
      _socket.on("updateRoom", (data) {
        dataOfRoom.value = data;
        if (data["isJoin"] != true) {
          // Timer logic
        }
      });

      _socket.on("points", (point) {
        if (point["details"] != null) {
          double dx = point['details']["dx"];
          double dy = point['details']["dy"];
          points.add(TouchPoints(
            paint: Paint()
              ..strokeCap = strokeType.value
              ..isAntiAlias = true
              ..color = selectedColor.value.withOpacity(opacity.value)
              ..strokeWidth = strokeWidth.value,
            points: Offset(dx, dy),
          ));
        }
      });

      _socket.on("paint-brush", (data) {});
    });
  }

  void selectColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Color"),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor.value,
            onColorChanged: (color) {
              String colorString = color.toHexString();

              Map map = {
                'color': colorString,
                'roomName': dataOfRoom['roomName'],
              };

              _socket.emit("paint-brush", map);
            },
          ),
        ),
      ),
    );
  }

  void onPanUpdate(Offset position) {
    _socket.emit("paint", {
      'details': {'dx': position.dx, 'dy': position.dy},
      'roomName': dataOfRoom['roomName'],
    });
  }

  void onPanEnd() {
    _socket
        .emit("paint", {'details': null, 'roomName': dataOfRoom['roomName']});
  }

  void clearCanvas() => points.clear();
}
