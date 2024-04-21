package com.example.flutter_printer;

import android.content.Context;

import androidx.annotation.NonNull;

import com.gprinter.bean.PrinterDevices;
import com.gprinter.utils.CallbackListener;
import com.gprinter.utils.Command;
import com.gprinter.utils.ConnMethod;

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
      String mac = call.argument("mac");

      if(mac == null || mac.isEmpty()){
        throw new IllegalArgumentException("MAC不能为空");
      }

      PrinterDevices blueTooth=new PrinterDevices.Build()
              .setContext(context)
              .setConnMethod(ConnMethod.BLUETOOTH)
              .setMacAddress(mac)
              .setCommand(Command.ESC)
              .setCallbackListener(callbackListener)
              .build();
      printer.connect(blueTooth);
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
