import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sim_api/models/sim_api_http_method.dart';
import 'package:sim_api/models/sim_api_http_response.dart';
import 'package:sim_api/sim_api.dart';

void main() {
  late SimApi<int> simApi;

  setUp(() {
    simApi = SimApi<int>(defaultDelay: 100);
    simApi.registerRoute('/items');
    simApi.registerRoute(
      '/items',
      method: SimApiHttpMethod.put,
      haveRouteParameters: true,
    );
    simApi.registerRoute(
      '/items',
      method: SimApiHttpMethod.patch,
      haveRouteParameters: true,
    );
    simApi.registerRoute(
      '/items',
      method: SimApiHttpMethod.delete,
      haveRouteParameters: true,
    );
  });

  group('SimApi Tests', () {
    test('POST request stores data correctly', () async {
      final url = Uri.parse('/items');
      final body = {'name': 'item1'};
      final response = await simApi.post(url, body: body);

      expect(response.statusCode, 201);
      final data = simApi.currentData['/items'];
      expect(data?.values.first, body);
    });

    test('GET request retrieves data correctly', () async {
      final url = Uri.parse('/items');
      final body = {'name': 'item2'};
      await simApi.post(url, body: body);

      final response = await simApi.get(url);
      final responseBody = jsonDecode(response.body);
      expect(response.statusCode, 200);
      expect(responseBody, anyElement(containsPair('name', 'item2')));
    });

    test('PUT request updates data correctly', () async {
      final body = {'name': 'item3'};
      final postResponse =
          await simApi.post(Uri.parse('/items'), body: {'name': 'item2'});
      final postResponseBody = jsonDecode(postResponse.body);

      final url = Uri.parse('/items/${postResponseBody['id']}');
      await simApi.put(url, body: body);

      final response = await simApi.get(url);
      final responseBody = jsonDecode(response.body);
      expect(response.statusCode, 200);
      expect(responseBody, body);
    });

    test('PATCH request partially updates data correctly', () async {
      final postResponse =
          await simApi.post(Uri.parse('/items'), body: {'name': 'item4'});
      final postResponseBody = jsonDecode(postResponse.body);

      final url = Uri.parse('/items/${postResponseBody['id']}');
      final updatedData = {'name': 'updatedItem'};
      await simApi.patch(url, body: updatedData);

      final response = await simApi.get(url);
      final responseBody = jsonDecode(response.body);
      expect(response.statusCode, 200);
      expect(responseBody, updatedData);
    });

    test('DELETE request removes data correctly', () async {
      var postResponse =
          await simApi.post(Uri.parse('/items'), body: {'name': 'item5'});
      final postResponseBody = jsonDecode(postResponse.body);

      final url = Uri.parse('/items/${postResponseBody['id']}');
      await simApi.delete(url);

      final response = await simApi.get(url);
      expect(response.statusCode, 404);
    });

    test('Registers and uses routes correctly', () async {
      simApi.registerRoute(
        '/custom',
        method: SimApiHttpMethod.get,
        handler: (
          url, {
          body,
          headers,
          required delete,
          required get,
          required patch,
          required post,
          required put,
        }) async {
          return SimApiHttpResponse.ok({'message': 'custom route'});
        },
      );

      final response = await simApi.get(Uri.parse('/custom'));
      final responseBody = jsonDecode(response.body);
      expect(response.statusCode, 200);
      expect(responseBody, {'message': 'custom route'});
    });

    test('Delay is applied correctly', () async {
      final url = Uri.parse('/items');
      final startTime = DateTime.now();
      await simApi.post(url, body: {'name': 'item6'});
      final endTime = DateTime.now();

      final delayTime = endTime.difference(startTime).inMilliseconds;
      expect(delayTime, greaterThanOrEqualTo(100));
    });

    test('Clear data removes all stored data', () async {
      final url = Uri.parse('/items');
      await simApi.post(url, body: {'name': 'item7'});

      simApi.clearData();

      final response = await simApi.get(url);
      final responseBody = jsonDecode(response.body);
      expect(response.statusCode, 200);
      expect(responseBody, []);
    });
  });
}
