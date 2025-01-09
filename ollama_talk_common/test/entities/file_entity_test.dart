import 'dart:convert';

import 'package:ollama_talk_common/src/entities/file_entity.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  test('Create FileEntity with constructor', () {
    final entity = FileEntity(
      fileName: 'example.txt',
      content: 'This is a sample content.',
      errorMessage: null,
    );

    expect(entity.fileName, 'example.txt');
    expect(entity.content, 'This is a sample content.');
    expect(entity.errorMessage, null);
  });

  test('Create FileEntity fromJson and toJson', () {
    final json = {
      'fileName': 'example.txt',
      'content': 'This is a sample content.',
      'errorMessage': 'File not found',
    };

    final entity = FileEntity.fromJson(json);
    final jsonBack = entity.toJson();

    expect(jsonBack['fileName'], json['fileName']);
    expect(jsonBack['content'], json['content']);
    expect(jsonBack['errorMessage'], json['errorMessage']);
  });

  test('Create FileEntity using factory file', () {
    final entity = FileEntity.file('example.txt', 'This is a factory content.');

    expect(entity.fileName, 'example.txt');
    expect(entity.content, 'This is a factory content.');
    expect(entity.errorMessage, null);
  });

  test('Create FileEntity using factory error', () {
    final entity = FileEntity.error('error.txt', 'File not found');

    expect(entity.fileName, 'error.txt');
    expect(entity.content, ''); // error時のcontentは空文字
    expect(entity.errorMessage, 'File not found');
  });

  test('json', () {
    final file = File('test/entities/file_entity_test.text');
    expect(file.existsSync(), true);
    final entity =
        FileEntity(fileName: 'fileName', content: file.readAsStringSync());
    final jsonData = entity.toJson();
    final source = jsonEncode(jsonData);
    final convertedData = FileEntity.fromJson(jsonDecode(source));
    expect(convertedData.content, file.readAsStringSync());
  });

  test('jsonList', () {
    final file = File('test/entities/file_entity_test.text');
    expect(file.existsSync(), true);
    final entities = [
      FileEntity(fileName: 'fileName1', content: file.readAsStringSync()),
      FileEntity(fileName: 'fileName2', content: file.readAsStringSync()),
    ];
    final source = jsonEncode(entities);
    expect(RegExp('MaterialApp').allMatches(source).length, 2);

    final jsonList = jsonDecode(source) as List<dynamic>;
    final result = jsonList.map((e) => FileEntity.fromJson(e)).toList();

    expect(result[0].fileName, 'fileName1');
    expect(result[1].fileName, 'fileName2');

    expect(result[0].content, file.readAsStringSync());
    expect(result[1].content, file.readAsStringSync());
  });
}
