import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_printer_example/find_blue_tooth/blue_tooth_off_screen.dart';

class FindBluetoothScreen extends StatelessWidget {
  const FindBluetoothScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FlutterBlue.instance.state,
        builder: (context, snapshot) {
          BluetoothState? state = snapshot.data as BluetoothState?;
          if (state != BluetoothState.on) {
            return BluetoothOffScreen(state: state);
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Find Devices'),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    StreamBuilder<List<ScanResult>>(
                      stream: FlutterBlue.instance.scanResults,
                      initialData: const [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data!.map((r) {
                          return ListTile(
                            title: Text(r.device.name),
                            subtitle: Text(r.device.id.toString()),
                            onTap: () => Navigator.pop(context, r.device.id.toString()),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: StreamBuilder<bool>(
                stream: FlutterBlue.instance.isScanning,
                initialData: false,
                builder: (c, snapshot) {
                  if (snapshot.data!) {
                    return FloatingActionButton(
                      child: const Icon(Icons.stop),
                      onPressed: () => FlutterBlue.instance.stopScan(),
                      backgroundColor: Colors.red,
                    );
                  } else {
                    return FloatingActionButton(
                        child: const Icon(Icons.search),
                        onPressed: () => FlutterBlue.instance.startScan(timeout: const Duration(seconds: 4)));
                  }
                },
              ),
            );
          }
        });
  }
}
