import 'package:flutter/services.dart';

class AppToGrade {
  /// 通道
  static const MethodChannel channel = const MethodChannel('app_to_grade');

  static gradeApp({String? packageName, String? AppleId}) {
    Map<String, String> _map = {};
    if (packageName != null) {
      _map = {"packageName": packageName};
    } else if (AppleId != null) {
      _map = {"AppleId": AppleId};
    }
    channel.invokeMethod("gradeAndFeedBack", _map);
  }
}
