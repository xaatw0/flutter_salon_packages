import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ServiceLocator {
  static ServiceLocator? _instance;
  ServiceLocator._internal() {}

  static ServiceLocator getInstance([@visibleForTesting ServiceLocator? mock]) {
    if (mock != null) {
      return mock;
    }

    _instance ??= ServiceLocator._internal();
    return _instance!;
  }

  final httpClient = http.Client();
  final ollamaTalkServerUrl = 'http://192.168.1.33:8080';
}
