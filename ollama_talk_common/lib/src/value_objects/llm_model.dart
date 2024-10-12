import 'abstract_value_object.dart';

class LlmModel extends AbstractValueObject<String> {
  const LlmModel(super._value, {this.id});

  final int? id;

  static List<LlmModel> fromJsonList(dynamic source) {
    final list = source as List<dynamic>;
    return list.map((e) => LlmModel(e as String)).toList();
  }

  static LlmModel fromJson(dynamic source) {
    return LlmModel(source['name'], id: source['id']);
  }
}
