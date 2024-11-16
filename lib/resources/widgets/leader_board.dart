import 'package:flutter/material.dart';

class LeaderBoard extends StatelessWidget {
  const LeaderBoard({super.key, required this.dataOfRoom});

  final Map dataOfRoom;

  @override
  Widget build(BuildContext context) {
    // Sorting players by points in descending order
    List players = List.from(dataOfRoom['players']);
    players.sort((a, b) => b['points'].compareTo(a['points']));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Leaderboard",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index == 0
                          ? "${players[index]['playerName']} (winner)"
                          : players[index]['playerName'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${players[index]['points']} points",
                      style: const TextStyle(fontSize: 16),
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          index == 0 ? Colors.green : Colors.blueAccent,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
