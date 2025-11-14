import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/services/network/api_service.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('ApiService', () {
    test('exposes provided Dio client', () {
      final dio = Dio();
      final service = ApiService(dio: dio);

      expect(service.client, same(dio));
    });

    test('setHeaderToken stores Authorization header', () {
      final dio = Dio();
      final service = ApiService(dio: dio);

      service.setHeaderToken('token-abc');

      expect(service.client.options.headers['Authorization'],
          'Bearer token-abc');
    });

    test('get forwards parameters to Dio', () async {
      final mockDio = MockDio();
      final expectedResponse = Response<String>(
        data: 'ok',
        requestOptions: RequestOptions(path: '/articles'),
      );
      final options = Options(headers: {'custom': 'value'});
      final query = {'page': 1};

      when(mockDio.get<String>(
        '/articles',
        data: null,
        queryParameters: query,
        options: options,
        cancelToken: null,
        onReceiveProgress: null,
      )).thenAnswer((_) async => expectedResponse);

      final service = ApiService(dio: mockDio);

      final result = await service.get<String>(
        path: '/articles',
        queryParameters: query,
        options: options,
      );

      expect(result, same(expectedResponse));
      verify(mockDio.get<String>(
        '/articles',
        data: null,
        queryParameters: query,
        options: options,
        cancelToken: null,
        onReceiveProgress: null,
      )).called(1);
    });

    test('post, put and delete proxies calls to Dio', () async {
      final mockDio = MockDio();
      final service = ApiService(dio: mockDio);
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/resource'),
      );
      final payload = {'key': 'value'};

      when(mockDio.post<dynamic>(
        '/resource',
        data: payload,
        queryParameters: null,
        options: null,
        cancelToken: null,
        onSendProgress: null,
        onReceiveProgress: null,
      )).thenAnswer((_) async => response);
      when(mockDio.put<dynamic>(
        '/resource',
        data: payload,
        queryParameters: null,
        options: null,
        cancelToken: null,
        onSendProgress: null,
        onReceiveProgress: null,
      )).thenAnswer((_) async => response);
      when(mockDio.delete<dynamic>(
        '/resource',
        data: payload,
        queryParameters: null,
        options: null,
        cancelToken: null,
      )).thenAnswer((_) async => response);

      expect(
        await service.post(path: '/resource', data: payload),
        same(response),
      );
      expect(
        await service.put(path: '/resource', data: payload),
        same(response),
      );
      expect(
        await service.delete(path: '/resource', data: payload),
        same(response),
      );

      verify(mockDio.post<dynamic>(
        '/resource',
        data: payload,
        queryParameters: null,
        options: null,
        cancelToken: null,
        onSendProgress: null,
        onReceiveProgress: null,
      )).called(1);
      verify(mockDio.put<dynamic>(
        '/resource',
        data: payload,
        queryParameters: null,
        options: null,
        cancelToken: null,
        onSendProgress: null,
        onReceiveProgress: null,
      )).called(1);
      verify(mockDio.delete<dynamic>(
        '/resource',
        data: payload,
        queryParameters: null,
        options: null,
        cancelToken: null,
      )).called(1);
    });
  });
}
