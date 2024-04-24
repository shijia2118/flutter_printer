import 'dart:math';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:flutter_printer_example/utils/convert_utils.dart';
import 'package:oktoast/oktoast.dart';

class BarCodeScreen extends StatefulWidget {
  const BarCodeScreen({Key? key}) : super(key: key);

  @override
  State<BarCodeScreen> createState() => _BarCodeScreenState();
}

class _BarCodeScreenState extends State<BarCodeScreen> {
  String? barCode;

  void generateBarCode() {
    Random random = Random();
    barCode = random.nextInt(100000000).toString();

    setState(() {});
  }

  void printBarCode() async {
    final status = await FlutterPrinter.printerState();
    if (status == '0') {
      if (barCode != null) {
        final result = await FlutterPrinter.printBarcode(
          barCode: barCode!,
        );
        showToast(result);
      }
    } else {
      showToast(ConvertUtils.printerState(status));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buttons = SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: generateBarCode,
            child: const Text('生成条形码'),
          ),
          TextButton(
            onPressed: printBarCode,
            child: const Text('打印条形码'),
          ),
        ],
      ),
    );

    Widget barCodeWidget = barCode == null
        ? const SizedBox()
        : BarcodeWidget(
            data: barCode!,
            width: 200,
            height: 50,
            barcode: Barcode.code128(),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('打印条形码')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buttons,
            const SizedBox(height: 50),
            if (barCode != null) barCodeWidget,
          ],
        ),
      ),
    );
  }
}
