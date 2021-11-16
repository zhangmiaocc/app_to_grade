package com.example.app_to_grade;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AppToGradePlugin */
public class AppToGradePlugin implements FlutterPlugin, MethodCallHandler {

  static Context context;
  
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "app_to_grade");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } if (call.method.equals("gradeAndFeedBack")) {
      String packageName = call.argument("packageName");
      goAPPMarketToUpdate(context, packageName);
    } else {
      result.notImplemented();
    }
  }

  /**
   * 跳转应用市场 更新下载
   *
   * @param context
   */
  public static void goAPPMarketToUpdate(Context context, String packageName) {
    try {
      String googlep_package = "com.android.vending";
      Uri uri = Uri.parse("market://details?id=" + packageName);
      Intent intent = new Intent(Intent.ACTION_VIEW, uri);
      intent.setPackage(googlep_package);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
    } catch (Exception e) {
      e.printStackTrace();
      //如果没有谷歌play 那么就跳转h5页面下载
      goToBrowser(context, "https://play.google.com/store/apps/details?id=" + packageName);
    }
  }

  /**
   * 如果没有应用市场 跳转浏览器进行下载
   *
   * @param context
   * @param url
   */
  public static void goToBrowser(Context context, String url) {
    try {
      Uri uri = Uri.parse(url);
      Intent intent = new Intent(Intent.ACTION_VIEW, uri);
      context.startActivity(intent);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
