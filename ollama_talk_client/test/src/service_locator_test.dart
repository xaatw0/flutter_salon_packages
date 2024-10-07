import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_client/src/service_locator.dart';
import 'service_locator_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ServiceLocator>()])
void main() {
  test('real', () {
    final target = ServiceLocator.getInstance();
    expect(target.ollamaTalkServerUrl, '192.168.1.33:8080');
  });

  test('mock', () {
    final mock = MockServiceLocator();
    when(mock.ollamaTalkServerUrl).thenReturn('test.com');
    expect(mock.ollamaTalkServerUrl, 'test.com');

    expect(
      ServiceLocator.getInstance(mock).ollamaTalkServerUrl,
      'test.com',
    );
  });
}
