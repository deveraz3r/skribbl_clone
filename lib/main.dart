import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/utils/routes/routes.dart';
import 'package:skribbl_clone/views/create_room_view.dart';
import 'package:skribbl_clone/views/home_view.dart';
import 'package:skribbl_clone/views/join_room_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skribbl Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      getPages: Routes.appRoutes(),
    );
  }
}
