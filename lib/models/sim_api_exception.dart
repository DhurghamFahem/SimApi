/// Exception class for handling errors in the sim api.
class SimApiException implements Exception {
  /// The error message associated with the exception.
  final String message;

  /// Creates a new instance of `SimApiException` with a given [message].
  SimApiException(this.message);

  @override
  String toString() => 'SimApiException: $message';

  /// Factory constructor for creating an exception with a generic unknown error message.
  factory SimApiException.unKown() {
    return SimApiException("Un known error.");
  }

  /// Factory constructor for creating an exception indicating that a route is not registered.
  ///
  /// [route] The route that was not registered.
  factory SimApiException.routeIsNotRegistered(String route) {
    return SimApiException("This route $route is not registered.");
  }
}
