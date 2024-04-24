class ConvertUtils {
  static String printerState(String status) {
    // 打印机状态转换
    switch (status) {
      case '0':
        return '状态正常';
      case '1':
        return '状态走纸';
      case '2':
        return '状态缺纸';
      case '3':
        return '状态开盖';
      case '4':
        return '状态过热';
      case '-1':
        return '获取状态失败';
      default:
        return status;
    }
  }
}
