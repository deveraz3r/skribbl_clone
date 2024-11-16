import 'package:flutter/material.dart';

class ScoreBoardDrawer extends StatelessWidget {
  const ScoreBoardDrawer({super.key, required this.dataOfRoom});

  final Map dataOfRoom;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10,
          ),
          child: Column(
            children: [
              const Text(
                "Score board",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: dataOfRoom['players'].length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        dataOfRoom["players"][index]["playerName"].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        dataOfRoom["players"][index]["points"].toString(),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
