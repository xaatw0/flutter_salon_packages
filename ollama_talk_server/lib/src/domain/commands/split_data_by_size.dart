import 'dart:async';
import 'split_data.dart';

class SplitDataBySize implements ISplitData {
  const SplitDataBySize(this.dataLength, this.shiftLength)
      : assert(0 < dataLength),
        assert(0 < shiftLength),
        assert(shiftLength <= dataLength);

  final int dataLength;
  final int shiftLength;

  @override
  Stream<String> execute(String data) async* {
    final length = data.length;
    for (int i = 0; i < length; i += shiftLength) {
      final end = i + dataLength < length ? i + dataLength : null;
      final partOfData = data.substring(i, end);
      yield partOfData;
    }
  }
}
