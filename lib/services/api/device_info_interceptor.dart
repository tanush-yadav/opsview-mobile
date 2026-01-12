import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoInterceptor extends Interceptor {
  String? _imei;
  String? _model;
  String? _brand;
  String? _appVersion;
  double? _latitude;
  double? _longitude;
  DateTime? _locationFetchedAt;

  // How long to cache location before fetching again
  static const _locationCacheDuration = Duration(minutes: 5);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_imei == null ||
        _model == null ||
        _brand == null ||
        _appVersion == null) {
      await _initDeviceInfo();
    }

    // Refresh location if not cached or cache expired
    if (_shouldRefreshLocation()) {
      await _fetchLocation();
    }

    options.headers['x-imei'] = _imei;
    options.headers['x-mod'] = _model;
    options.headers['x-brd'] = _brand;
    options.headers['x-appv'] = _appVersion;
    options.headers['x-lat'] = _latitude?.toString() ?? '0.0';
    options.headers['x-lng'] = _longitude?.toString() ?? '0.0';

    handler.next(options);
  }

  bool _shouldRefreshLocation() {
    if (_latitude == null || _longitude == null) return true;
    if (_locationFetchedAt == null) return true;
    return DateTime.now().difference(_locationFetchedAt!) >
        _locationCacheDuration;
  }

  Future<void> _fetchLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission if denied (user may have declined on splash)
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationFetchedAt = DateTime.now();
    } catch (e) {
      // Location fetch failed, keep previous values or 0.0
    }
  }

  Future<void> _initDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    _appVersion = packageInfo.version;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _model = androidInfo.model;
        _brand = androidInfo.brand;
        _imei = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _model = iosInfo.name;
        _brand = 'Apple';
        _imei = iosInfo.identifierForVendor;
      }
    } catch (e) {
      // Fallback or log error
    }
  }
}
