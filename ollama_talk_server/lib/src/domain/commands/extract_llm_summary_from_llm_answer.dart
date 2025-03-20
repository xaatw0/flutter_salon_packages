import 'dart:convert';

import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:convert/convert.dart';

class _SummaryFromLlmResponse {
  final String title;
  final List<String> contents;

  _SummaryFromLlmResponse({
    required this.title,
    required this.contents,
  });

  // JSON からクラスを作成する factory メソッド
  factory _SummaryFromLlmResponse.fromJson(Map<String, dynamic> json) {
    return _SummaryFromLlmResponse(
      title: json['title'],
      contents: List<String>.from(json['contents']),
    );
  }
}

class ExtractLlmSummaryFromLlmAnswer
    implements ICommand<String, _SummaryFromLlmResponse?> {
  final _regexForJsonPart = RegExp(r'```json([^`]*)', multiLine: true);

  @override
  _SummaryFromLlmResponse? execute(String data) {
    final jsonPart = extractJsonPart(data);
    if (jsonPart.isEmpty) {
      return null;
    }

    try {
      return _SummaryFromLlmResponse.fromJson(jsonDecode(jsonPart));
    } catch (e) {
      return null;
    }
  }

  String extractJsonPart(String text) {
    final matchPart = _regexForJsonPart.firstMatch(text);
    return matchPart?.group(1) ?? '';
  }
}
