import 'package:mockito/annotations.dart';
import 'package:objectbox/objectbox.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'service_locator_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>(), MockSpec<ServiceLocator>()])
void main() {
  test('デフォルト値', () {
    final target = ServiceLocator.instance;

    expect(target, same(ServiceLocator.instance));
    expect(target.httpClient, isA<http.Client>());
    expect(target.apiRoot, 'localhost:8080');
    expect(target.store, isA<Store>());
  });

  test('モック', () async {
    final mockClient = MockClient();
    when(mockClient.get(Uri.parse('http://test.com/index')))
        .thenAnswer((_) async => http.Response('body', 200));

    final mock = MockServiceLocator();
    when(mock.apiRoot).thenReturn('test.com');
    when(mock.httpClient).thenReturn(mockClient);

    ServiceLocator.setMock(mock);
    final target = ServiceLocator.instance;

    expect(target, same(ServiceLocator.instance));
    expect(target.apiRoot, 'test.com');
    expect(target.httpClient, isA<MockClient>());

    final response =
        await target.httpClient.get(Uri.parse('http://test.com/index'));
    expect(response.body, 'body');
    expect(response.statusCode, 200);
  });
}
