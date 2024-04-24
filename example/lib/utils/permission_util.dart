import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  //BLUE_TOOTH_SCAN权限
  static Future<bool> blueToothScan() async {
    var status = await Permission.bluetoothScan.status;

    if (status == PermissionStatus.granted) {
      return true;
    } else {
      status = await Permission.bluetoothScan.request();
    }

    return status == PermissionStatus.granted;
  }

  //存储权限
  static Future<bool> storage() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }
}
