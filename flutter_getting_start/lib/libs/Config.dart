
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

class Config{
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static const bool DEBUG = !kReleaseMode;

  static Map<String, dynamic> _cached_common_headers;

  static Future<Map<String, dynamic>> get common_headers async =>
      _cached_common_headers ??= await initPlatformState();

  static void putHeader(String key, dynamic val){
    _cached_common_headers.putIfAbsent(key, () => val);
  }
  static void removeHeader(String key){
    _cached_common_headers.remove(key);
  }
  static void setHeadersFromJson(String json){
    _cached_common_headers.addAll(jsonDecode(json));
  }

  static Future<Map<String, dynamic>> initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String, dynamic> deviceData;
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await _deviceInfoPlugin.androidInfo, packageInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo, packageInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'error': 'Failed to get platform version.'
      };
    }
    return deviceData;
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build, PackageInfo info) {
    return <String, dynamic>{
    /*  'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,*/

      'sys_platform':'android',
      'sys_version':build.version.sdkInt,
      'sys_versioncode':build.version.release,
      'sys_deviceid':build.model,
      'app_channel':"",
      'app_versionname': info.version,
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data, PackageInfo info) {
    return <String, dynamic>{
     /* 'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,*/

      'sys_platform':'ios',
      'sys_version':data.systemVersion,
      'sys_versioncode':data.systemVersion,
      'sys_deviceid':data.utsname.machine + data.model,
      'app_channel':"",
      'app_versionname': info.version,
    };
  }
}

/**
Headers.Builder set = headersOrigin.newBuilder()
    .set("sys_platform", "android")
    .set("sys_version", String.valueOf(Build.VERSION.SDK_INT))
    .set("sys_versioncode", Build.VERSION.RELEASE)
    .set("sys_deviceid", DeviceUtil.getDeviceId())
    .set("app_channel", AppConfig.get().getChannel())
    .set("app_versionname", AppConfig.get().getVersionName());
 */