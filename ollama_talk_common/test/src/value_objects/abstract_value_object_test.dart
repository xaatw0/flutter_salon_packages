import 'dart:convert';

import 'package:ollama_talk_common/src/value_objects/abstract_value_object.dart';
import 'package:test/test.dart';

class StringValueObject extends AbstractValueObject<String> {
  StringValueObject(super.value);
}

class IntValueObject extends AbstractValueObject<int> {
  IntValueObject(super.value);
}

class TestClass {
  const TestClass(this.stringValueObject, this.intValueObject);
  final StringValueObject stringValueObject;
  final IntValueObject intValueObject;

  String toJson() => '''
"a":${jsonEncode(stringValueObject)},
"b":${jsonEncode(intValueObject)}
  '''
      .trim();
}

void main() {
  test('toJson', () {
    final stringValue = StringValueObject('value');
    expect(jsonEncode(stringValue), '"value"');

    final intValue = IntValueObject(-1);
    expect(jsonEncode(intValue), '-1');
  });

  test('fromJson', () {
    final stringValue = StringValueObject(jsonDecode('"value"'));
    expect(stringValue(), 'value');

    final intValue = IntValueObject(jsonDecode('1'));
    expect(intValue(), 1);
  });

  test('map', () {
    final value = TestClass(
      StringValueObject('value'),
      IntValueObject(-1),
    );
    final json = jsonEncode(value);
    expect(json.trim(), '"\\"a\\":\\"value\\",\\n\\"b\\":-1"');
  });
}
