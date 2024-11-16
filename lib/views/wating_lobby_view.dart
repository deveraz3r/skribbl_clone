import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WatingLobbyView extends StatefulWidget {
  const WatingLobbyView({super.key, required this.dataofRoom});

  final Map dataofRoom;

  @override
  State<WatingLobbyView> createState() => _WatingLobbyViewState();
}

class _WatingLobbyViewState extends State<WatingLobbyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Text(
                "Wating looby",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Players joined: ${widget.dataofRoom["players"].length}/${widget.dataofRoom['occupancy']}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.dataofRoom["players"].length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "${widget.dataofRoom["players"][index]["playerName"]}",
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText("${widget.dataofRoom["roomName"]}"),
                    IconButton(
                      onPressed: () {
                        try {
                          Clipboard.setData(
                            ClipboardData(text: widget.dataofRoom["roomName"]),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to Clipboard!'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to copy to clipboard.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
