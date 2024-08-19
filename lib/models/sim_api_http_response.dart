import 'dart:convert';

import 'package:http/http.dart';

class SimApiHttpResponse {
  /// Creates a `Response` for a successful request with an OK status.
  ///
  /// **Parameters**:
  /// - `data`: The data to include in the response body.
  ///
  /// **Returns**:
  /// - A `Response` with a 200 status code and the provided data.
  static ok(dynamic data) {
    // Convert the data to JSON
    var jsonData = jsonEncode(data);

    // Create a Response object with a status code of 200 (OK)
    return Response(jsonData, 200,
        headers: {'Content-Type': 'application/json'});
  }

  /// Creates a `Response` for a resource creation with a Created status.
  ///
  /// **Parameters**:
  /// - `id`: The ID of the newly created resource.
  ///
  /// **Returns**:
  /// - A `Response` with a 201 status code and the resource ID in the body.
  static created(dynamic id) {
    // Convert the data to JSON
    var jsonData = jsonEncode({'id': id});

    // Create a Response object with a status code of 201 (OK)
    return Response(jsonData, 201,
        headers: {'Content-Type': 'application/json'});
  }

  /// Creates a `Response` for a successful request with no content.
  ///
  /// **Returns**:
  /// - A `Response` with a 204 status code and an empty body.
  static noContent() {
    // Create a Response object with a status code of 204 (OK)
    return Response('', 204);
  }

  /// Creates a `Response` for a request with a Method Not Allowed status.
  ///
  /// **Returns**:
  /// - A `Response` with a 405 status code and a message indicating that the method is not allowed.
  static methodNotAllowed() {
    // Create a Response object with a status code of 405 (Method Not Allowed)
    return Response('{"error": "Method Not Allowed"}', 405,
        headers: {'Content-Type': 'application/json'});
  }

  /// Creates a `Response` for a request with a Not Found status.
  ///
  /// **Returns**:
  /// - A `Response` with a 404 status code and a message indicating that the resource was not found.
  static notFound() {
    // Create a Response object with a status code of 404 (Not Found)
    return Response('{"error": "Not Found"}', 404,
        headers: {'Content-Type': 'application/json'});
  }
}
