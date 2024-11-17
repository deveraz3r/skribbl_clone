import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/models/my_custom_painter.dart';
import 'package:skribbl_clone/resources/widgets/leader_board.dart';
import 'package:skribbl_clone/resources/widgets/score_board_drawer.dart';
import 'package:skribbl_clone/view_models/paint_view_model.dart';
import 'package:skribbl_clone/views/wating_lobby_view.dart';

class PaintView extends StatelessWidget {
  PaintView({super.key});

  final PaintViewModel controller = Get.put(PaintViewModel());

  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    void selectColor() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Choose Color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: controller.selectedColor.value,
              onColorChanged: (color) {
                String colorString = color.toHexString();

                Map map = {
                  'color': colorString,
                  'roomName': controller.dataOfRoom.value['roomName'],
                };

                controller.socket.emit("color-change", map);
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

    return GetBuilder<PaintViewModel>(builder: (_) {
      if (controller.dataOfRoom.value.isEmpty ||
          controller.dataOfRoom.value['isJoin'] == null) {
        // There is no data returned from server, show loading icon
        return const Center(child: CircularProgressIndicator());
      } else if (controller.dataOfRoom.value['isJoin'] == true) {
        // Game created, waiting for other players, show waiting room
        return WatingLobbyView(dataofRoom: controller.dataOfRoom.value);
      } else if (controller.dataOfRoom.value["currentRound"] >
          controller.dataOfRoom.value["maxRounds"]) {
        // Game has ended, show leaderboard
        controller.timer!.cancel();
        return LeaderBoard(dataOfRoom: controller.dataOfRoom.value);
      } else {
        // Game is in progress, show game screen
        return Scaffold(
          key: _scaffoldkey,
          drawer: Obx(
            () => ScoreBoardDrawer(dataOfRoom: controller.dataOfRoom.value),
          ),
          resizeToAvoidBottomInset:
              true, // Ensures that the body resizes when keyboard opens
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Skribbl"),
            leading: IconButton(
              onPressed: () {
                _scaffoldkey.currentState?.openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Drawing Canvas
              SizedBox(
                width: width,
                height: height * 0.45,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    controller.paintPoints(details.localPosition);
                  },
                  onPanStart: (details) {
                    controller.paintPoints(details.localPosition);
                  },
                  onPanEnd: (details) {
                    controller.paintPoints(null);
                  },
                  child: SizedBox.expand(
                    child: Container(
                      color: Colors.red, //TODO: remove this
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Obx(
                          () => RepaintBoundary(
                            child: CustomPaint(
                              painter: MyCustomPainter(
                                pointsList: controller.points.value,
                              ),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Controls for drawing (Color, Stroke Width, Clear Canvas)
              controller.clientData.value["playerName"] ==
                      controller.dataOfRoom.value["turn"]["playerName"]
                  ? Row(
                      children: [
                        Obx(
                          () => IconButton(
                            onPressed: selectColor,
                            icon: Icon(
                              Icons.color_lens,
                              color: controller.selectedColor.value,
                            ),
                          ),
                        ),
                        Obx(
                          () => Expanded(
                            child: Slider(
                              min: 1,
                              max: 10,
                              label:
                                  "Stroke width ${controller.strokeWidth.value}",
                              value: controller.strokeWidth.value,
                              activeColor: controller.selectedColor.value,
                              onChanged: (value) {
                                Map map = {
                                  'width': value,
                                  'roomName':
                                      controller.dataOfRoom.value['roomName'],
                                };

                                controller.socket
                                    .emit("strokeWidth-change", map);
                              },
                            ),
                          ),
                        ),
                        Obx(
                          () => IconButton(
                            onPressed: () {
                              controller.socket.emit("clear-canvas", {
                                "roomName":
                                    controller.dataOfRoom.value['roomName']
                              });
                            },
                            icon: Icon(
                              Icons.layers_clear,
                              color: controller.selectedColor.value,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              // Word to Guess (Underscores for others, Word for Drawer)
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: controller.listOfAlphabets.value,
                ),
              ),
              // Chat Messages
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: controller.messages.value.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(controller.messages.value[index][0]
                            .toString()), // Sender name
                        subtitle: Text(
                          controller.messages.value[index][1]
                              .toString(), // Message
                          style: TextStyle(
                            color: controller.messages.value[index][2]
                                ? Colors.green
                                : Colors.black, // Correct guesses in green
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Guess Word Input (Only for non-drawers)
              controller.clientData.value["playerName"] ==
                      controller.dataOfRoom.value["turn"]["playerName"]
                  ? const SizedBox()
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.messageTextController,
                            decoration: const InputDecoration(
                              hintText: "Guess word",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (controller
                                .messageTextController.text.isNotEmpty) {
                              controller.socket.emit("message", {
                                'message':
                                    controller.messageTextController.text,
                                'playerName':
                                    controller.clientData.value['playerName'],
                                'roomName':
                                    controller.dataOfRoom.value['roomName'],
                                'roundTime': 60,
                                'timeTaken': 60 - controller.start.value,
                              });
                              controller.messageTextController.clear();
                            }
                          },
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          floatingActionButton: Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              onPressed: () {},
              elevation: 7,
              backgroundColor: Colors.white,
              child: Obx(
                () => Text(
                  "${controller.start.value}",
                  style: const TextStyle(color: Colors.black, fontSize: 22),
                ),
              ),
            ),
          ),
        );
      }
    });
  }
}
