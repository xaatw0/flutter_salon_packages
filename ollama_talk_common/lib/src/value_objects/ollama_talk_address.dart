import 'package:ollama_talk_common/ollama_talk_common.dart';

class OllamaTalkAddress extends AbstractValueObject<String> {
  static const _default = 'localhost:8080';
  OllamaTalkAddress._(super.value);

  factory OllamaTalkAddress.create([String? value]) {
    return OllamaTalkAddress._(value ?? _default);
  }
}
