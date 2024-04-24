import 'package:flutter/material.dart';
import 'package:flutter_printer/connect_status.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:flutter_printer_example/bar_code_screen/bar_code_screen.dart';
import 'package:flutter_printer_example/command.dart';
import 'package:flutter_printer_example/find_blue_tooth/find_blue_tooth_screen.dart';
import 'package:flutter_printer_example/utils/convert_utils.dart';
import 'package:flutter_printer_example/utils/permission_util.dart';
import 'package:oktoast/oktoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String statusMsg = '未知';
  String? macAddress;
  String printerStatus = '未知';

  Command command = Command.esc_58;

  List<int> labelGaps = [0, 1, 2, 3, 4];

  late int currentGap;

  @override
  void initState() {
    super.initState();

    currentGap = labelGaps.first;

    /// 打印机连接状态监听
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
          statusMsg = '断开连接';
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

  ///搜索附近蓝牙设备
  void searchBluetooth() async {
    final hasPermission = await PermissionUtil.blueToothScan();

    if (!hasPermission) {
      showToast('没有BLUETOOTH_SCAN权限');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FindBluetoothScreen()),
    );
    if (result != null) {
      setState(() {
        macAddress = result;
      });
    }
  }

  ///连接打印机
  void printerConnect() async {
    final hasPermission = await PermissionUtil.blueToothScan();

    if (hasPermission) {
      if (macAddress == null || macAddress!.isEmpty) {
        showToast('MAC地址不能为空');
        return;
      }
      await FlutterPrinter.printerConnect(macAddress!, command: command.name);
    } else {
      showToast('没有BLUETOOTH_SCAN权限');
      return;
    }
  }

  void onChanged(Command? command) {
    if (command != null) {
      this.command = command;
      setState(() {});
    }
  }

  void onSelectGap(int? gap) {
    if (gap != null) {
      setState(() {
        currentGap = gap;
      });
    }
  }

  ///查询打印机状态
  void getPrinterStatus() async {
    final status = await FlutterPrinter.printerState();
    setState(() {
      printerStatus = ConvertUtils.printerState(status);
    });
  }

  ///打印案例
  void print() async {
    final status = await FlutterPrinter.printerState();
    setState(() {
      printerStatus = ConvertUtils.printerState(status);
    });

    if (status == '0') {
      final result = await FlutterPrinter.print(command: command.name, gap: currentGap);
      showToast(result);
    }
  }

  ///打印XML
  void printXML() async {
    final status = await FlutterPrinter.printerState();
    setState(() {
      printerStatus = ConvertUtils.printerState(status);
    });

    if (status == '0') {
      final result = await FlutterPrinter.printXML(command: command.name);
      showToast(result);
    }
  }

  ///打印PDF
  void printPDF() async {
    final hasPermission = await PermissionUtil.storage();
    if (!hasPermission) {
      showToast('没有存储权限');
      return;
    }

    final status = await FlutterPrinter.printerState();
    setState(() {
      printerStatus = ConvertUtils.printerState(status);
    });

    if (status == '0') {
      final result = await FlutterPrinter.printPDF(command: command.name);
      showToast(result);
    }
  }

  ///针式打印
  void printDot() async {
    final result = await FlutterPrinter.printDot();
    showToast(result);
  }

  ///打印菜单
  void printMenu() async {
    final status = await FlutterPrinter.printerState();
    setState(() {
      printerStatus = ConvertUtils.printerState(status);
    });

    if (status == '0') {
      final result = await FlutterPrinter.printMenu(command: command.name);
      showToast(result);
    }
  }

  ///打印条形码
  void printBarCode() async {
    final status = await FlutterPrinter.printerState();
    setState(() {
      printerStatus = ConvertUtils.printerState(status);
    });

    if (status == '0') {
      final result = await FlutterPrinter.printXML(command: command.name);
      showToast(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    ///打印机类型
    Widget selectPrinterType = Row(
      children: [
        Flexible(
          flex: 1,
          child: RadioListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(Command.esc_58.name),
            value: Command.esc_58,
            groupValue: command,
            onChanged: onChanged,
          ),
        ),
        Flexible(
          flex: 1,
          child: RadioListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(Command.esc_80.name),
            value: Command.esc_80,
            groupValue: command,
            onChanged: onChanged,
          ),
        ),
        Flexible(
          flex: 1,
          child: RadioListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(Command.tsc.name),
            value: Command.tsc,
            groupValue: command,
            onChanged: onChanged,
          ),
        ),
      ],
    );

    ///标签缝隙
    Widget labelGapSelect = command == Command.tsc
        ? Row(
            children: [
              const Text('标签缝隙'),
              const SizedBox(width: 20.0),
              Expanded(
                child: DropdownButton<int>(
                  value: currentGap,
                  items: labelGaps
                      .map(
                        (e) => DropdownMenuItem<int>(
                          value: labelGaps.indexOf(e),
                          child: Text(labelGaps.indexOf(e).toString()),
                        ),
                      )
                      .toList(),
                  onChanged: onSelectGap,
                ),
              ),
            ],
          )
        : const SizedBox.shrink();

    return OKToast(
      backgroundColor: const Color(0xFF3A3A3A),
      position: ToastPosition.center,
      radius: 8,
      textPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('打印机demo'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('打印机类型选择:'),
                selectPrinterType,
                labelGapSelect,
                const SizedBox(height: 25),
                const Text('第一步:'),
                OutlinedButton(
                  onPressed: searchBluetooth,
                  child: const Text('搜索蓝牙'),
                ),
                Text('MAC地址:' + (macAddress == null ? '无' : macAddress!)),
                const SizedBox(height: 25),
                const Text('第二步:'),
                OutlinedButton(
                  onPressed: printerConnect,
                  child: const Text('连接打印机'),
                ),
                Text('连接状态:' + statusMsg),
                const SizedBox(height: 25),
                const Text('第三步:'),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BarCodeScreen()),
                  ),
                  child: const Text('打印条形码'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
