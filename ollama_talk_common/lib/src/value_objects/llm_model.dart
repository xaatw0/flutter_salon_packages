import 'abstract_value_object.dart';

class LlmModel extends AbstractValueObject<String> {
  const LlmModel(super._value);

  static List<LlmModel> fromJsonList(dynamic source) {
    final list = source as List<dynamic>;
    return list.map((e) => LlmModel(e as String)).toList();
  }
}
