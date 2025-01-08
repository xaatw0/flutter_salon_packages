import 'package:ollama_talk_common/src/utilities/validators/ip_address_and_port_validator.dart';
import 'package:test/test.dart';

void main() {
  group('sample for making', () {
    test('ip address', () {
      // https://qiita.com/aikamanami11/items/aef0b7046d3b44efd681
      final regIpAddress = RegExp(
          r'^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$');
      expect(regIpAddress.hasMatch('192.168.1.10'), true);
      expect(regIpAddress.hasMatch('0.0.0.0'), true);
      expect(regIpAddress.hasMatch('10.10.10.10'), true);
      expect(regIpAddress.hasMatch('255.255.255.255'), true);

      expect(regIpAddress.hasMatch('255.255.255.256'), false);
      expect(regIpAddress.hasMatch('255.255.255.255 '), false);
      expect(regIpAddress.hasMatch('abc'), false);
    });

    test('hostname', () {
      final regHostName = RegExp(
          r'^(?!\-)[\-0-9A-Za-z]{1,63}(?<!\-)(?:\.(?!\-)[\-0-9A-Za-z]{1,63}(?<!\-))*$');
      expect(regHostName.hasMatch('localhost'), true);
      expect(regHostName.hasMatch('local-host'), true);
      expect(regHostName.hasMatch('test.jp'), true);

      expect(regHostName.hasMatch('local_host'), false);
    });
  });

  final validator = IpOrHostnameAndPortValidator();

  group('IpOrHostnameAndPortValidator', () {
    test('Valid IP address and port', () {
      expect(() => validator.validate('192.168.0.1:8080'), returnsNormally);
    });

    test('Valid hostname and port', () {
      expect(() => validator.validate('example.com:8080'), returnsNormally);
      expect(() => validator.validate('sub.domain.example.com:1234'),
          returnsNormally);
      expect(() => validator.validate('localhost:11434'), returnsNormally);
      expect(() => validator.validate('server-name:1234'), returnsNormally);
    });

    test('Invalid IP address', () {
      expect(() => validator.validate('256.256.256.256:8080'),
          throwsA(isA<FormatException>()));
    });

    test('Invalid hostname', () {
      expect(() => validator.validate('invalid_hostname:1234'),
          throwsA(isA<FormatException>()));
    });

    test('Invalid port number', () {
      expect(() => validator.validate('example.com:70000'),
          throwsA(isA<FormatException>()));
      expect(() => validator.validate('192.168.0.1:0'),
          throwsA(isA<FormatException>()));
    });

    test('Missing port', () {
      expect(() => validator.validate('192.168.0.1'),
          throwsA(isA<FormatException>()));
      expect(() => validator.validate('example.com'),
          throwsA(isA<FormatException>()));
    });

    test('Empty input', () {
      expect(() => validator.validate(''), throwsA(isA<FormatException>()));
    });

    test('Whitespace input', () {
      expect(() => validator.validate('   '), throwsA(isA<FormatException>()));
    });
  });
}
