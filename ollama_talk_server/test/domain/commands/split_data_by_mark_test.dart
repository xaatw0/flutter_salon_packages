import 'dart:convert';

import 'package:ollama_talk_server/src/domain/commands/split_data_by_mark.dart';
import 'package:test/test.dart';

void main() async {
  group('正規表現', () {
    final regMark1 = RegExp(r'(?<!#)(?=## )');
    final regMark2 = RegExp('(?=### )');

    test('否定', () {
      expect(regMark1.hasMatch('## '), true);
      expect(regMark1.hasMatch('### '), false);
    });

    test('中項目', () {
      final sentence = '## 1';
      expect(regMark1.hasMatch(sentence), true);
      expect(regMark2.hasMatch(sentence), false);
    });
    test('小項目', () {
      final sentence = '### 1';
      expect(regMark1.hasMatch(sentence), false);
      expect(regMark2.hasMatch(sentence), true);
    });
    test('両方', () {
      final sentence = '## 1 ### 2';
      expect(regMark1.allMatches(sentence).length, 1);
      expect(regMark2.allMatches(sentence).length, 1);
    });

    test('混在', () {
      final sentence =
          '## 1 ### 1.1 ### 1.2 ### 1.3 ## 2 ### 2.1 ## 3 ### 3.1 ';
      expect(regMark1.allMatches(sentence).length, 3);
      expect(regMark2.allMatches(sentence).length, 3 + 1 + 1);

      final paragraph = sentence.split(regMark1);
      expect(
        paragraph,
        ['## 1 ### 1.1 ### 1.2 ### 1.3 ', '## 2 ### 2.1 ', '## 3 ### 3.1 '],
      );
      expect(paragraph[0].split(regMark2),
          ['## 1 ', '### 1.1 ', '### 1.2 ', '### 1.3 ']);
      expect(paragraph[1].split(regMark2), ['## 2 ', '### 2.1 ']);
      expect(paragraph[2].split(regMark2), ['## 3 ', '### 3.1 ']);
    });

    test('前に何かある', () {
      final sentence = 'abc## 1 ### 2  def## 3 ### 4';
      expect(regMark1.allMatches(sentence).length, 2);
      expect(regMark2.allMatches(sentence).length, 2);

      final paragraph = sentence.split(regMark1);
      expect(paragraph.length, 3);
      expect(paragraph[0], 'abc');
      expect(paragraph[1], '## 1 ### 2  def');
      expect(paragraph[2], '## 3 ### 4');
    });

    test('前に何かあるかの判断', () {
      final sentence1 = '## 1 ### 2  def## 3 ### 4';
      final sentence2 = 'abc## 1 ### 2  def## 3 ### 4';

      expect(sentence1.indexOf(regMark1) == 0, true);
      expect(sentence2.indexOf(regMark1) == 0, false);
    });
  });

  final regMark1 = RegExp(r'(?<!#)(?=## )');
  final regMark2 = RegExp('(?=### )');

  final target = SplitDataByMark(regMark1, regMark2);

  group('extract', skip: true, () {
    test('単項目', () {
      expectLater(
          target.extract('## a', '## ', 2), emitsInOrder([' a', emitsDone]));
    });
    test('複数項目 前にデータあり', () {
      expectLater(target.extract('abc## a## b', '## ', 2),
          emitsInOrder(['abc', '## a', '## b', emitsDone]));
    });
    test('複数項目 前にデータなし', () {
      expectLater(target.extract('## a## b', '## ', 2),
          emitsInOrder(['## a', '## b', emitsDone]));
    });

    test('複数項目 データ', () {
      expectLater(target.extract('## a\nabc## b\nabc', '## ', 2),
          emitsInOrder(['## a\nabc', '## b\nabc', emitsDone]));
    });
  });

  group('区切り', () {
    test('大中項目なし', () {
      final stream = target.execute('data');

      expectLater(stream, emitsInOrder(['data', emitsDone]));
    });

    test('項目名のみ', () {
      expectLater(
          target.execute('## 1'),
          emitsInOrder([
            '## 1',
            emitsDone,
          ]));
    });
    test('項目に連続で空白なし', () {
      expectLater(
          target.execute('ABC## 1'),
          emitsInOrder([
            '## 1',
            emitsDone,
          ]));
    });
    test('項目に連続で空白あり', () {
      expectLater(
          target.execute('ABC ## 1 ## 2 '),
          emitsInOrder([
            '## 1 ',
            '## 2 ',
            emitsDone,
          ]));
    });

    test('大項目のみ', () {
      final stream = target.execute('## data1## data2');

      expectLater(
          stream,
          emitsInOrder([
            '## data1',
            '## data2',
            emitsDone,
          ]));
    });
  });

  group('マークダウンの大中項目', () {
    test('最低限', () {
      final data = '## 中項目 1 ### 小項目 2';

      final stream = target.execute(data);

      expectLater(
          stream,
          emitsInOrder([
            '## 中項目 1 ### 小項目 2',
            emitsDone,
          ]));
    });
    test('実践', () {
      final data = '''
## 中項目
1
### 小項目
2
### 小項目
3
## 中項目
4
### 小項目
5
### 小項目
6''';

      final stream = target.execute(data);
      expectLater(
          stream,
          emitsInOrder([
            '## 中項目\n1\n### 小項目\n2\n',
            '## 中項目\n1\n### 小項目\n3\n',
            '## 中項目\n4\n### 小項目\n5\n',
            '## 中項目\n4\n### 小項目\n6',
            emitsDone,
          ]));
    });
  });
}
