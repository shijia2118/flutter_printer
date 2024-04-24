import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_printer/connect_status.dart';

class FlutterPrinter {
  static const MethodChannel _channel = MethodChannel('flutter_printer');
  static const BasicMessageChannel<dynamic> connectChannel =
      BasicMessageChannel("com.example.flutter_printer_connect", StandardMessageCodec());

  // 连接打印机
  static Future<void> printerConnect(String mac, {required String command}) async {
    await _channel.invokeMethod('printer_connect', {
      'mac': mac,
      'command': command,
    });
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

  // 查询打印机状态
  static Future<String> printerState() async {
    return await _channel.invokeMethod('printer_state');
  }

  // 打印案例
  static Future<String> print({required String command, int? gap}) async {
    return await _channel.invokeMethod('print', {'command': command, 'gap': gap});
  }

  // 打印XML
  static Future<String> printXML({required String command}) async {
    return await _channel.invokeMethod('print_xml', {'command': command});
  }

  // 打印PDF
  static Future<String> printPDF({required String command}) async {
    return await _channel.invokeMethod('print_pdf', {'command': command});
  }

  // 针式打印(仅针对ESC类型)
  static Future<String> printDot() async {
    return await _channel.invokeMethod('print_dot');
  }

  // 打印菜单(仅针对ESC类型)
  static Future<String> printMenu({required String command}) async {
    return await _channel.invokeMethod('print_menu', {'command': command});
  }

  // 打印条形码
  static Future<String> printBarcode({
    required String barCode,
    int? width,
    int? height,
  }) async {
    return await _channel.invokeMethod(
      'print_barcode',
      {
        'barCode': barCode,
        'width': width,
        'height': height,
      },
    );
  }
}
