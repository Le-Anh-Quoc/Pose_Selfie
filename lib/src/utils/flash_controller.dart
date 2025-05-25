import 'package:flutter/services.dart';

class FlashController {
  static const MethodChannel _channel = MethodChannel('flash_control');

  static Future<void> turnOn() async {
    await _channel.invokeMethod('turnOn');
  }

  static Future<void> turnOff() async {
    await _channel.invokeMethod('turnOff');
  }
}
