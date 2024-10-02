import 'package:counter_app/domain/number_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberWithCommas', () {
    test('formats number with commas correctly', () {
      ThousandsSeparatedFormatter formatter = ThousandsSeparatedFormatter();
      expect(formatter.format(12345), '12,345');
      expect(formatter.format(987654321), '987,654,321');
      expect(formatter.format(1000), '1,000');
      expect(formatter.format(0), '0');
    });

    test('handles small numbers without commas', () {
      ThousandsSeparatedFormatter formatter = ThousandsSeparatedFormatter();
      expect(formatter.format(5), '5');
    });
  });

  group('KanjiNumber', () {
    test('formats number into Kanji correctly', () {
      KanjiNumberFormatter formatter = KanjiNumberFormatter();
      expect(formatter.format(5), '五');
      expect(formatter.format(15), '十五');
      expect(formatter.format(145), '百四十五');
      expect(formatter.format(345), '三百四十五');
      expect(formatter.format(1345), '千三百四十五');
      expect(formatter.format(2345), '二千三百四十五');
      expect(formatter.format(12345), '一万二千三百四十五');
      expect(formatter.format(99999), '九万九千九百九十九');
      expect(formatter.format(10000), '一万');
      expect(formatter.format(100000), '十万');
      expect(formatter.format(0), '零');

      expect(formatter.format(-5), '負の五');
      expect(formatter.format(-15), '負の十五');
      expect(formatter.format(-145), '負の百四十五');
      expect(formatter.format(-100000), '負の十万');
    });

    test('throws error for numbers out of range', () {
      KanjiNumberFormatter formatter = KanjiNumberFormatter();
      expect(() => formatter.format(100001), throwsArgumentError);
      expect(() => formatter.format(-100001), throwsArgumentError);
    });
  });

  group('LuigiFormatter', () {
    test('small number', () {
      SpelledOutFormatter formatter = SpelledOutFormatter();
      expect(formatter.format(0), 'zero');
      expect(formatter.format(1), 'one');
      expect(formatter.format(2), 'two');
      expect(formatter.format(3), 'three');
      expect(formatter.format(4), 'four');
      expect(formatter.format(5), 'five');
      expect(formatter.format(6), 'six');
      expect(formatter.format(7), 'seven');
      expect(formatter.format(8), 'eight');
      expect(formatter.format(9), 'nine');
      expect(formatter.format(10), 'ten');
      expect(formatter.format(11), 'eleven');
      expect(formatter.format(12), 'twelve');
      expect(formatter.format(13), 'thirteen');
      expect(formatter.format(14), 'fourteen');
      expect(formatter.format(15), 'fifteen');
      expect(formatter.format(16), 'sixteen');
      expect(formatter.format(17), 'seventeen');
      expect(formatter.format(18), 'eighteen');
      expect(formatter.format(19), 'nineteen');
      expect(formatter.format(20), 'twenty');
      expect(formatter.format(21), 'twenty one');
    });

    test('formats number into English words correctly', () {
      SpelledOutFormatter formatter = SpelledOutFormatter();
      expect(
          formatter.format(12345), 'twelve thousand three hundred forty five');
      expect(formatter.format(99999),
          'ninety nine thousand nine hundred ninety nine');
      expect(formatter.format(10000), 'ten thousand');
      expect(formatter.format(0), 'zero');
    });

    test('throws error for numbers out of range', () {
      SpelledOutFormatter formatter = SpelledOutFormatter();
      expect(() => formatter.format(100000), throwsArgumentError);
      expect(() => formatter.format(-1), throwsArgumentError);
    });
  });
}
