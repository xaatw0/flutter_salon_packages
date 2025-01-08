import 'package:ollama_talk_common/ollama_talk_common.dart';

class OllamaAddress extends AbstractValueObject<String> {
  static const _default = 'localhost:11434';
  const OllamaAddress._(super._value);

  factory OllamaAddress.create([String? address]) {
    if (address != null) {
      _validateFormat(address);
    }
    return OllamaAddress._(address ?? _default);
  }

  static void _validateFormat(String value) {}
}
