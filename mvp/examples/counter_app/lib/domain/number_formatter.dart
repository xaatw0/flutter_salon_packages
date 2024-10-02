sealed class NumberFormatter {
  String get name;
  String format(int value);
}

class ThousandsSeparatedFormatter implements NumberFormatter {
  const ThousandsSeparatedFormatter();
  @override
  String format(int number) {
    String numberString = number.toString();
    StringBuffer formattedNumber = StringBuffer();

    int count = 0;
    for (int i = numberString.length - 1; i >= 0; i--) {
      formattedNumber.write(numberString[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        formattedNumber.write(',');
      }
    }

    return formattedNumber.toString().split('').reversed.join();
  }

  @override
  String get name => 'ThousandsSeparatedFormatter';
}

class KanjiNumberFormatter implements NumberFormatter {
  const KanjiNumberFormatter();

  // 漢数字のマッピング
  static const List<String> kanjiNumbers = [
    '零',
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九'
  ];
  static const List<String> kanjiUnits = ['', '十', '百', '千'];
  static const List<String> higherUnits = ['', '万'];

  // フォーマットメソッド
  @override
  String format(int number) {
    if (number < -100000 || number > 100000) {
      throw ArgumentError('対応している範囲は-99999から99999までです。');
    }

    if (number == 0) {
      return kanjiNumbers[0]; // 0は特別に「零」
    }

    bool isMinus = number < 0;
    number = isMinus ? -number : number;

    String result = '';
    int unitGroupIndex = 0; // 「万」などの単位用のインデックス

    while (number > 0) {
      int group = number % 10000; // 4桁ごとに分ける
      if (group != 0) {
        result =
            _convertGroupToKanji(group) + higherUnits[unitGroupIndex] + result;
      }
      unitGroupIndex++;
      number ~/= 10000;
    }

    for (int i = 1; i < kanjiUnits.length; i++) {
      final replaceWord = kanjiNumbers[1] + kanjiUnits[i];
      result = result.replaceFirst(replaceWord, kanjiUnits[i]);
    }

    return (isMinus ? '負の' : '') + result;
  }

  // 4桁以内の数字を漢数字に変換するヘルパーメソッド
  String _convertGroupToKanji(int number) {
    String result = '';
    int digitIndex = 0;

    while (number > 0) {
      int digit = number % 10;
      if (digit != 0) {
        result = kanjiNumbers[digit] + kanjiUnits[digitIndex] + result;
      }
      digitIndex++;
      number ~/= 10;
    }

    return result;
  }

  @override
  String get name => 'KanjiNumberFormatter';
}

class SpelledOutFormatter implements NumberFormatter {
  const SpelledOutFormatter();
  // Basic English words for numbers
  static const List<String> englishNumbers = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen'
  ];

  // Tens multiples
  static const List<String> tens = [
    '',
    '',
    'twenty',
    'thirty',
    'forty',
    'fifty',
    'sixty',
    'seventy',
    'eighty',
    'ninety'
  ];

  // Higher units
  static const List<String> higherUnits = ['', 'thousand'];

  String format(int number) {
    if (number < 0 || number > 99999) {
      throw ArgumentError('The range supported is from 0 to 99999.');
    }

    if (number == 0) {
      return englishNumbers[0]; // Return "zero" for 0
    }

    String result = '';
    int unitGroupIndex = 0;

    while (number > 0) {
      int group = number % 1000;
      if (group != 0) {
        result = _convertGroupToEnglish(group) +
            ' ' +
            higherUnits[unitGroupIndex] +
            ' ' +
            result;
      }
      unitGroupIndex++;
      number ~/= 1000;
    }

    return result.trim();
  }

  String _convertGroupToEnglish(int number) {
    if (number == 0) return '';
    if (number < 20) {
      return englishNumbers[number];
    } else if (number < 100) {
      int tensPart = number ~/ 10;
      int onesPart = number % 10;
      return tens[tensPart] +
          (onesPart != 0 ? ' ' + englishNumbers[onesPart] : '');
    } else {
      int hundredsPart = number ~/ 100;
      int remainder = number % 100;
      return englishNumbers[hundredsPart] +
          ' hundred' +
          (remainder != 0 ? ' ' + _convertGroupToEnglish(remainder) : '');
    }
  }

  @override
  String get name => 'SpelledOutFormatter';
}
