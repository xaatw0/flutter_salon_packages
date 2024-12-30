import 'dart:convert';
import 'dart:io';

import 'package:ollama_talk_server/src/domain/rag/wiki_section_reader.dart';
import 'package:test/test.dart';

void main() {
  final file = File('test/domain/rag/wiki_section_reader_test.txt');
  final fileSakamoto =
      File('test/domain/rag/wiki_section_reader_test_sakamoto.txt');
  final fileItagaki =
      File('test/domain/rag/wiki_section_reader_test_itagaki.txt');

  test('ファイル確認', () {
    expect(file.existsSync(), true);
    expect(fileSakamoto.existsSync(), true);
    expect(fileItagaki.existsSync(), true);
  });

  test('テスト用ファイル', () {
    final data = '''
A
<h3>目次</h3>
B
<h3>C</h3>D
    '''
        .trim();

    final target = WikiSectionReader();
    final stream = Stream.fromIterable(LineSplitter().convert(data));

    expect(
      target.read(stream),
      emitsInOrder(
        ['A', '>目次</h3>B', '>C</h3>D', emitsDone],
      ),
    );
  });

  test('坂本龍馬、読み込み', () {
    final stream = fileSakamoto
        .openRead()
        .transform(utf8.decoder) // バイトを文字列に変換
        .transform(const LineSplitter()); // 行に分割

    final target = WikiSectionReader();

    expect(
      target.read(stream),
      emitsInOrder(
        [
          startsWith('<!DOCTYPE html>'),
          startsWith(' id="幼少年期'),
          startsWith(' id="江戸遊学'),
          startsWith(' id="土佐勤王党'),
        ],
      ),
    );
  });

  test('板垣退助、読み込み', () {
    final stream = fileSakamoto
        .openRead()
        .transform(utf8.decoder) // バイトを文字列に変換
        .transform(const LineSplitter()); // 行に分割

    final target = WikiSectionReader();

    expect(
      target.read(stream),
      emitsInOrder(
        [
          startsWith('<!DOCTYPE html>'),
          //        startsWith(' id="生い立ち'),
//          startsWith(' id="中岡慎太郎と胸襟を開いて国策を練る'),
        ],
      ),
    );
  });
}
