import 'dart:async';
import 'dart:io';

import 'package:ollama_talk_common/ollama_talk_common.dart';
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

  final OllamaAddress _ollamaHost =
      OllamaAddress.create(Platform.environment['OLLAMA_HOST']);
  OllamaAddress get ollamaHost => _ollamaHost;

  final OllamaTalkAddress _talkServerAddress =
      OllamaTalkAddress.create(Platform.environment['OLLAMA_TALK_HOST']);

  OllamaTalkAddress get talkServerAddress => _talkServerAddress;

  late final TalkServer _ollamaTalkServer = TalkServer(
    _httpClient,
    _store,
    OllamaServer(_httpClient, _ollamaHost),
  );

  /// Ollama Talk Server(LLMを使用したチャット用のサーバ)への参照
  TalkServer get ollamaTalkServer => _ollamaTalkServer;
}
