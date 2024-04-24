import 'package:flutter/material.dart';
import 'package:flutter_printer_example/home_page.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OKToast(
      backgroundColor: Color(0xFF3A3A3A),
      position: ToastPosition.center,
      radius: 8,
      textPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "打印机demo",
        home: HomePage(),
      ),
    );
  }
}
