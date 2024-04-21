import 'package:flutter/material.dart';
import 'package:flutter_printer/connect_status.dart';
import 'package:flutter_printer/flutter_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String statusMsg = '未知';
  String macAddress = 'MAC';

  @override
  void initState() {
    super.initState();

    FlutterPrinter.addConnectListener((status) {
      switch (status) {
        case ConnectStatus.onConnecting:
          statusMsg = '连接中...';
          break;
        case ConnectStatus.onCheckCommand:
          statusMsg = '查询中...';
          break;
        case ConnectStatus.onSuccess:
          statusMsg = '连接成功';
          break;
        case ConnectStatus.onDisconnect:
          statusMsg = '已断开';
          break;
        case ConnectStatus.onFailure:
          statusMsg = '连接失败';
          break;
        default:
          break;
      }

      setState(() {});
    });
  }

  void printerConnect() async {
    await FlutterPrinter.printerConnect(macAddress);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('打印机'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: printerConnect,
                child: const Text('连接打印机'),
              ),
              Text(statusMsg),
            ],
          ),
        ),
      ),
    );
  }
}
