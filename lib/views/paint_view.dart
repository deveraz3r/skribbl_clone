import 'dart:async';

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
  Map clientData = Get.arguments["data"];
  final String screenFrom = Get.arguments["from"];
  Map dataOfRoom = {};

  //contains Offset points to draw on screen
  List<TouchPoints> points = [];
  //generate blank spaces/hints for given word
  List<Widget> listofAlphabets = [];
  // each index will have name[0] and message[1]
  List<List> messages = [];
  final TextEditingController _messageTextController = TextEditingController();
  int gussedUserCounter = 0;
  int start = 60;
  late Timer _timer;

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

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  void startTimer() {
    const Duration oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (start == 0) {
        //change turn if all players have gussed correct word or time runs out
        _socket.emit("change-turn", {dataOfRoom['roomName']});
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  //Socket io client connection
  void connect() {
    _socket = IO.io("http://192.168.102.1:3000", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    if (screenFrom == "createRoom") {
      _socket.emit("create-room", clientData);
    } else if (screenFrom == "joinRoom") {
      _socket.emit("join-room", clientData);
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
          getWord();
        });

        if (data["isJoin"] != true) {
          //start the timer
          startTimer();
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

      //message
      _socket.on("message", (data) {
        bool isCorrectWord = data['isCorrectWord'];
        setState(() {
          if (isCorrectWord) gussedUserCounter++;
          messages.add([
            data['playerName'],
            data['message'],
            isCorrectWord,
          ]);
        });

        //change turn if all players have gussed correct word or time runs out
        if (gussedUserCounter == dataOfRoom['players'].length - 1) {
          _socket.emit("change-turn", {dataOfRoom['roomName']});
        }
      });

      //change turn
      _socket.on("change-turn", (data) {
        String word = dataOfRoom['word'];

        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  dataOfRoom = data;
                  getWord();
                  gussedUserCounter = 0;
                  start = 0;
                  points.clear();
                });
                Navigator.of(context).pop(); //TODO: remove warning
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                content: Text("Word was $word"),
              );
            });
      });
    });
  }

  void getWord() {
    String word = dataOfRoom['word'];
    listofAlphabets.clear();

    for (int i = 0; i < word.length; i++) {
      if (clientData["playerName"] == dataOfRoom['turn']['playerName']) {
        listofAlphabets
            .add(Text(word[i], style: const TextStyle(color: Colors.black)));
      } else {
        listofAlphabets
            .add(const Text("_", style: TextStyle(color: Colors.black)));
      }
    }
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
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
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
                        Map map = {
                          'width': value,
                          'roomName': dataOfRoom['roomName'],
                        };

                        _socket.emit("strokeWidth-change", map);
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: listofAlphabets, //word to guess
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index][0].toString()), //sender name
                      subtitle: Text(
                        messages[index][1].toString(), //message
                        style: TextStyle(
                          color:
                              messages[index][2] ? Colors.green : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageTextController,
                      decoration: const InputDecoration(
                        hintText: "Guess word",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_messageTextController.text.isNotEmpty) {
                        _socket.emit("message", {
                          'message': _messageTextController.text,
                          'playerName': clientData['playerName'],
                          'roomName': dataOfRoom['roomName'],
                          'roundTime': 60,
                          'timeTaken': 60 - start,
                        });
                        _messageTextController.clear();
                      }
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          )
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.all(10),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            "$start",
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
