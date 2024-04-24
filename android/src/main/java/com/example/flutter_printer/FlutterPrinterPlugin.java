package com.example.flutter_printer;

import android.Manifest;
import android.content.Context;
import android.os.Build;
import android.os.Message;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.gprinter.bean.PrinterDevices;
import com.gprinter.command.EscCommand;
import com.gprinter.utils.CallbackListener;
import com.gprinter.utils.Command;
import com.gprinter.utils.ConnMethod;
import com.gprinter.utils.LogUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Vector;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.StandardMessageCodec;

/** FlutterPrinterPlugin */
public class FlutterPrinterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware{
  private MethodChannel channel;
  private Context context;
  BasicMessageChannel<Object> connectChannel; //打印机连接状态渠道
  com.example.flutter_printer.Printer printer = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_printer");
    BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();

    channel.setMethodCallHandler(this);
    printer = Printer.getInstance();
    connectChannel =  new BasicMessageChannel<>(messenger, "com.example.flutter_printer_connect", new StandardMessageCodec());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("printer_connect")) {
      //连接打印机
      String mac = call.argument("mac");
      String cd = call.argument("command");

      if(mac == null || mac.isEmpty()){
        throw new IllegalArgumentException("MAC不能为空");
      }

      Command command = Command.ESC;
      if(cd != null && cd.equals("tsc")){
        command = Command.TSC;
      }

      PrinterDevices blueTooth=new PrinterDevices.Build()
              .setContext(context)
              .setConnMethod(ConnMethod.BLUETOOTH)
              .setMacAddress(mac)
              .setCommand(command)
              .setCallbackListener(callbackListener)
              .build();
      printer.connect(blueTooth);
    } else if(call.method.equals("printer_state")) {
      if (printer.getPortManager()==null){
        result.success("打印机未连接");
        return;
      }
      //获取打印机状态
      Command command = printer.getPortManager().getCommand();
      try {
        int status = printer.getPrinterState(command);
        result.success(String.valueOf(status));
      } catch (IOException e) {
        e.printStackTrace();
        result.success(e.getMessage());
      }
    } else if(call.method.equals("print")){
      //打印案例
      String cd = call.argument("command");
      if(cd == null){
        return;
      }

      if (printer.getPortManager()==null){
        result.success("打印机未连接");
        return;
      }

      Vector<Byte> data = null;
      if(cd.equals("esc_58")){
        data = PrintContent.getReceiptChinese(context,384);
      }else if(cd.equals("esc_80")){
        data = PrintContent.getReceiptChinese(context,576);
      }else if(cd.equals("tsc")){
        Integer gap = call.argument("gap");
        if(gap == null){
          gap = 0;
        }
        data = PrintContent.getLabel(context,gap);
      }

      try {
        boolean printResult = printer.getPortManager().writeDataImmediately(data);
        if (printResult) {
          result.success("发送成功");
        }else {
          result.success("发送失败");
        }
        LogUtils.e("send result",result);
      } catch (IOException e) {
        e.printStackTrace();
        result.success("打印失败" + e.getMessage());
      } catch (Exception e){
        result.success("打印失败" + e.getMessage());
      }
    } else if(call.method.equals("print_xml")){
      //打印XML
      String cd = call.argument("command");
      if(cd == null){
        return;
      }

      if (printer.getPortManager()==null){
        result.success("打印机未连接");
        return;
      }

      EscCommand esc = new EscCommand();
      esc.addInitializePrinter();
      // 打印图片  光栅位图  384代表打印图片像素  0代表打印模式
      // 58mm打印机 可打印区域最大点数为 384 ，80mm 打印机 可打印区域最大点数为 576 例子为80mmd打印机
      esc.addPrintAndLineFeed();
      try {
        boolean printResult = false;
        if(cd.equals("esc_58")){
          esc.drawImage(PrintContent.getBitmap(context), 384);
          printResult = printer.getPortManager().writeDataImmediately(esc.getCommand());
        } else if(cd.equals("esc_80")){
          esc.drawImage(PrintContent.getBitmap(context), 576);
          printResult = printer.getPortManager().writeDataImmediately(esc.getCommand());

          byte[] cut = {0x0A, 0x1d, 0x56, 0x01};//切刀
          printer.getPortManager().writeDataImmediately(cut);
        }else if(cd.equals("tsc")){
          printResult =  printer.getPortManager().writeDataImmediately(PrintContent.getXmlBitmap(context));
        }
        if (printResult) {
          result.success("发送成功");
        }else {
          result.success("发送失败");
        }
      } catch (IOException e) {
        result.success("打印失败:"+e.getMessage());
      } catch (Exception e){
        result.success("打印失败:"+e.getMessage());
      }
    } else if(call.method.equals("print_pdf")){
      //打印PDF
      String cd = call.argument("command");
      if(cd == null){
        return;
      }

      try {
        if (printer.getPortManager()==null){
          result.success("打印机未连接");
          return;
        }

        File file = null;
        try {
          file= new File(context.getExternalCacheDir(), "WalmartFile.pdf");
          if (!file.exists()) {
            // Since PdfRenderer cannot handle the compressed asset file directly, we copy it into
            // the cache directory.
            InputStream asset = context.getAssets().open("WalmartFile.pdf");
            FileOutputStream output = new FileOutputStream(file);
            final byte[] buffer = new byte[1024];
            int size;
            while ((size = asset.read(buffer)) != -1) {
              output.write(buffer, 0, size);
            }
            asset.close();
            output.close();
          }
        }catch (IOException e){
          result.success("获取PDF失败");
          return;
        }
        boolean printerResult = false;

        if(cd.equals("esc_58")){
          printerResult = printer.getPortManager().writePDFToEsc(file,384);
        } else if(cd.equals("esc_80")){
          printerResult = printer.getPortManager().writePDFToEsc(file,576);

          byte[] cut = {0x0A, 0x1d, 0x56, 0x01};//切刀
          printer.getPortManager().writeDataImmediately(cut);
        }else if(cd.equals("tsc")){
          printerResult=  printer.getPortManager().writePDFToTsc(file,576,0,true,true,false,160);
        }
        if (printerResult) {
          result.success("发送成功");
        }else {
          result.success("发送失败");
        }
        LogUtils.e("send result",result);
      } catch (IOException e) {
        result.success("打印失败"+e.getMessage());
      }catch (Exception e){
        result.success("打印失败"+e.getMessage());
      }

    } else if(call.method.equals("print_dot")){
      //针式打印
      if (printer.getPortManager()==null){
        result.success("打印机未连接");
        return;
      }

      try {
        boolean printerResult=  printer.getPortManager().writeDataImmediately(PrintContent.getDotPrintCommand("abababab","123456789"));
        if (printerResult) {
          result.success("发送成功");
        }else {
          result.success("发送失败");
        }
        LogUtils.e("send result",result);
      } catch (IOException e) {
        result.success("打印失败"+e.getMessage());
      }catch (Exception e){
        result.success("打印失败"+e.getMessage());
      }
    } else if(call.method.equals("print_menu")){
      //打印XML
      String cd = call.argument("command");
      if(cd == null){
        return;
      }

      //打印菜单
      if (printer.getPortManager()==null){
        result.success("打印机未连接");
        return;
      }

      try {
        boolean printerResult=  printer.getPortManager().writeDataImmediately(cd.equals("esc_58")? PrintContent.get58Menu(context): PrintContent.get80Menu(context));
        if (printerResult) {
          result.success("发送成功");
        }else {
          result.success("发送失败");
        }
        LogUtils.e("send result",result);
      } catch (IOException e) {
        result.success("打印失败"+e.getMessage());
      }catch (Exception e){
        result.success("打印失败"+e.getMessage());
      }
    }  else if(call.method.equals("print_barcode")){
      // 条形码打印
      if (printer.getPortManager()==null){
        result.success("打印机未连接");
        return;
      }

      try {
        String barCode = call.argument("barCode");
        Integer width = call.argument("width");
        Integer height = call.argument("height");

        if(barCode == null) {
          result.success("条形码不能为空");
          return;
        }

        if(width == null) width = 200;
        if(height == null) height = 50;

        boolean printerResult=  printer.getPortManager().writeDataImmediately(PrintContent.printBarCode(barCode,width,height));
        if (printerResult) {
          result.success("发送成功");
        }else {
          result.success("发送失败");
        }
        LogUtils.e("send result",result);
      } catch (IOException e) {
        result.success("打印失败"+e.getMessage());
      }catch (Exception e){
        result.success("打印失败"+e.getMessage());
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    context = binding.getActivity().getApplicationContext();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    context = null;
  }

  com.gprinter.utils.CallbackListener callbackListener = new CallbackListener() {
    @Override
    public void onConnecting() {
      connectChannel.send("0");
    }

    @Override
    public void onCheckCommand() {
      connectChannel.send("1");
    }

    @Override
    public void onSuccess(PrinterDevices printerDevices) {
      connectChannel.send("2");
    }

    @Override
    public void onReceive(byte[] data) {

    }

    @Override
    public void onFailure() {
      connectChannel.send("3");
    }

    @Override
    public void onDisconnect() {
      connectChannel.send("4");
    }
  };

}
