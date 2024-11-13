import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/models/my_custom_painter.dart';
import 'package:skribbl_clone/models/touch_points.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintView extends StatefulWidget {
  const PaintView({super.key});

  @override
  State<PaintView> createState() => _PaintViewState();
}

class _PaintViewState extends State<PaintView> {
  Map dataOfRoom = Get.arguments["data"];
  final String screenFrom = Get.arguments["from"];
  List<TouchPoints> points = [];

  //paint brush
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;

  //socket object
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    connect();
  }

  //Socket io client connection
  void connect() {
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

    //listen to socket
    _socket.onConnect((_) {
      if (kDebugMode) {
        print("Connected!");
      }

      //listen to event "updateRoom", when data is recived update the rooms data
      _socket.on("updateRoom", (data) {
        setState(() {
          dataOfRoom = data;
        });

        if (data["isJoin"] != true) {
          //start the timer
        }
      });

      //draw on points recived by server
      _socket.on("points", (point) {
        //draw points on scren
        if (point["details"] != null) {
          double dx = point['details']["dx"];
          double dy = point['details']["dy"];

          points.add(TouchPoints(
            paint: Paint()
              ..strokeCap = strokeType
              ..isAntiAlias = true
              ..color = selectedColor.withOpacity(opacity)
              ..strokeWidth = strokeWidth,
            points: Offset(dx, dy),
          ));
          setState(() {}); //TODO: remove this
        }
      });

      //change color
      _socket.on("color-change", (color) {
        setState(() {
          int value = int.parse(color, radix: 16);
          selectedColor = Color(value);
        });
      });

      //change color
      _socket.on("strokeWidth-change", (width) {
        setState(() {
          strokeWidth = double.parse(width);
        });
      });

      //strokeWidth change
      _socket.on("strokeWidth-change", (width) {
        setState(() {
          strokeWidth = width;
        });
      });

      //clear drawing
      _socket.on("clear-canvas", (_) {
        setState(() {
          points.clear();
        });
      });
    });
  }

  void selectColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Color"),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              String colorString = color.toHexString();

              Map map = {
                'color': colorString,
                'roomName': dataOfRoom['roomName'],
              };

              _socket.emit("color-change", map);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                height: height * 0.55,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    _socket.emit("paint", {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': dataOfRoom['roomName'],
                    });
                  },
                  onPanStart: (details) {
                    _socket.emit("paint", {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': dataOfRoom['roomName'],
                    });
                  },
                  onPanEnd: (details) {
                    _socket.emit("paint", {
                      'details': null,
                      'roomName': dataOfRoom['roomName'],
                    });
                  },
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: MyCustomPainter(pointsList: points),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: selectColor,
                    icon: Icon(
                      Icons.color_lens,
                      color: selectedColor,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 10,
                      label: "Stroke width $strokeWidth",
                      value: strokeWidth,
                      activeColor: selectedColor,
                      onChanged: (value) {
                        setState(() {
                          Map map = {
                            'width': value,
                            'roomName': dataOfRoom['roomName'],
                          };

                          _socket.emit("strokeWidth-change", map);
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _socket.emit(
                          "clear-canvas", {"roomName": dataOfRoom['roomName']});
                    },
                    icon: Icon(
                      Icons.layers_clear,
                      color: selectedColor,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
