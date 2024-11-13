import 'package:get/get.dart';
import 'package:skribbl_clone/views/create_room_view.dart';
import 'package:skribbl_clone/views/home_view.dart';
import 'package:skribbl_clone/views/join_room_view.dart';

import 'package:get/get_navigation/src/routes/get_route.dart';

import 'package:skribbl_clone/utils/routes/route_names.dart';
import 'package:skribbl_clone/views/paint_view.dart';

class Routes {
  static appRoutes() => [
        GetPage(
          name: RouteNames.home,
          page: () => const HomeView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 80),
        ),
        GetPage(
          name: RouteNames.createRoom,
          page: () => CreateRoomView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 80),
        ),
        GetPage(
          name: RouteNames.joinRoom,
          page: () => JoinRoomView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 80),
        ),
        GetPage(
          name: RouteNames.paintScreen,
          page: () => PaintView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 80),
        ),
      ];
}
