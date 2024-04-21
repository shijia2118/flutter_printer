import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_printer/connect_status.dart';

class FlutterPrinter {
  static const MethodChannel _channel = MethodChannel('flutter_printer');
  static const BasicMessageChannel<dynamic> connectChannel =
      BasicMessageChannel("com.example.flutter_printer_connect", StandardMessageCodec());

  // 连接打印机
  static Future<void> printerConnect(String mac) async {
    await _channel.invokeMethod('printer_connect',{'mac':mac});
  }

  // 打印机连接状态监听
  static void addConnectListener(Function(ConnectStatus) result) {
    connectChannel.setMessageHandler((message) async {
      if (message != null && message is String && message.isNotEmpty) {
        final status = int.tryParse(message);
        if (status == 0) {
          result(ConnectStatus.onConnecting);
        } else if (status == 1) {
          result(ConnectStatus.onCheckCommand);
        } else if (status == 2) {
          result(ConnectStatus.onSuccess);
        } else if (status == 3) {
          result(ConnectStatus.onFailure);
        } else if (status == 4) {
          result(ConnectStatus.onDisconnect);
        }
      }
    });
  }
}
