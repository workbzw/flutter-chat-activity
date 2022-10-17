import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:event_bus/event_bus.dart';

import 'event_bus_utils.dart';

class RouteUtils {
  static void route(BuildContext context, String location) {
    if (location != '/recents' &&
        location != '/search' &&
        location != '/library') {
      EventBusUtils().eventBus.fire(BottomNavEvent(false));
    } else {
      EventBusUtils().eventBus.fire(BottomNavEvent(true));
    }
    GoRouter.of(context).go(location);
  }

  static void back(BuildContext context) {
    GoRouter.of(context).pop();
  }
}

class BottomNavEvent {
  BottomNavEvent(this.show);

  bool show = true;
}
