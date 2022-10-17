import 'package:event_bus/event_bus.dart';

class EventBusUtils {
  // 提供了一个工厂方法来获取该类的实例.
  factory EventBusUtils() => _singleton;

  // 通过私有的具造方法_internal()隐藏了构造方法.
  EventBusUtils._internal() {
    init();
  }

  late final EventBus eventBus;
  // Static final修饰了_singleton，_singleton会在编译期被初始化，保证了特征3.
  static final EventBusUtils _singleton = EventBusUtils._internal();

  void init() {
    eventBus = EventBus();
  }
}
