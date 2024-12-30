import 'dart:async';
import 'dart:io';

import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

import '../../ollama_talk_server.dart';
import 'package:http/http.dart' as http;

class ServiceLocator {
  static ServiceLocator? _instance;
  static ServiceLocator get instance {
    _instance ??= ServiceLocator._();
    return _instance!;
  }

  ServiceLocator._();

  static setMock(ServiceLocator mock) {
    _instance = mock;
  }

  late final Store _store =
      Store(getObjectBoxModel(), directory: 'object-box-dir');
  Store get store => _store;

  final http.Client _httpClient = http.Client();
  http.Client get httpClient => _httpClient;

  final String _apiRoot = Platform.environment['API_URL'] ?? 'localhost:8080';
  String get apiRoot => _apiRoot;

  late final OllamaServer _ollamaServer = OllamaServer(httpClient, apiRoot);

  /// Ollama Server(LLMサーバ)への参照
  OllamaServer get ollamaServer => _ollamaServer;

  late final TalkServer _ollamaTalkServer =
      TalkServer(_httpClient, _apiRoot, _store, _ollamaServer);

  /// Ollama Talk Server(LLMを使用したチャット用のサーバ)への参照
  TalkServer get ollamaTalkServer => _ollamaTalkServer;
}
