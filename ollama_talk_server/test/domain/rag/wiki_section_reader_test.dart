import 'dart:io';

import 'package:test/test.dart';

void main() {
  final file = File('test/domain/rag/wiki_section_reader_test.json');

  test('ファイル確認', () {
    expect(file.existsSync(), true);
  });

  test('読み込み', () {
//    final stream =file.re
  });
}
