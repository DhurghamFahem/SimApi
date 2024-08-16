class SimApiHttpResponse {
  final int statusCode; // HTTP status code
  final dynamic body; // Response body content
  final Map<String, String> headers; // HTTP headers

  /// Constructs a `SimApiHttpResponse` instance with the specified status code, body, and headers.
  ///
  /// **Parameters**:
  /// - `statusCode`: The HTTP status code for the response.
  /// - `body`: The body of the response, which can be any type of data.
  /// - `headers`: Optional map of HTTP headers for the response. Defaults to an empty map.
  const SimApiHttpResponse({
    required this.statusCode,
    this.body,
    this.headers = const {},
  });

  /// Creates a `SimApiHttpResponse` for a successful request with an OK status.
  ///
  /// **Parameters**:
  /// - `data`: The data to include in the response body.
  ///
  /// **Returns**:
  /// - A `SimApiHttpResponse` with a 200 status code and the provided data.
  factory SimApiHttpResponse.ok(dynamic data) {
    return SimApiHttpResponse(
      statusCode: 200,
      body: data,
    );
  }

  /// Creates a `SimApiHttpResponse` for a resource creation with a Created status.
  ///
  /// **Parameters**:
  /// - `id`: The ID of the newly created resource.
  ///
  /// **Returns**:
  /// - A `SimApiHttpResponse` with a 201 status code and the resource ID in the body.
  factory SimApiHttpResponse.created(dynamic id) {
    return SimApiHttpResponse(
      statusCode: 201,
      body: {'id': id},
    );
  }

  /// Creates a `SimApiHttpResponse` for a successful request with no content.
  ///
  /// **Returns**:
  /// - A `SimApiHttpResponse` with a 204 status code and an empty body.
  factory SimApiHttpResponse.noContent() {
    return const SimApiHttpResponse(statusCode: 204, body: '');
  }

  /// Creates a `SimApiHttpResponse` for a request with a Method Not Allowed status.
  ///
  /// **Returns**:
  /// - A `SimApiHttpResponse` with a 405 status code and a message indicating that the method is not allowed.
  factory SimApiHttpResponse.methodNotAllowed() {
    return const SimApiHttpResponse(
        statusCode: 405, body: 'Method not allowed.');
  }

  /// Creates a `SimApiHttpResponse` for a request with a Not Found status.
  ///
  /// **Returns**:
  /// - A `SimApiHttpResponse` with a 404 status code and a message indicating that the resource was not found.
  factory SimApiHttpResponse.notFound() {
    return const SimApiHttpResponse(statusCode: 404, body: 'Not Found.');
  }
}
