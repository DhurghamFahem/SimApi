import 'package:sim_api/models/sim_api_http_method.dart';
import 'package:sim_api/models/sim_api_http_response.dart';
import 'package:sim_api/typedefs/route_handler.dart';

/// Abstract base class defining the interface for SimApi
abstract class SimApiBase<TId> {
  /// Simulates a POST request
  ///
  /// [url] The API route
  /// [body] The request body
  /// [headers] Optional headers for the request
  /// [id] Optional ID for the new resource (if not provided, one will be generated)
  ///
  /// Returns a `Future<SimApiHttpResponse>`, which represents the result of the simulated POST operation.
  Future<SimApiHttpResponse> post(Uri url,
      {Map<String, String>? headers, Object? body});

  /// Simulates a GET request
  ///
  /// [url] The API route
  /// [headers] Optional headers for the request
  ///
  /// Returns a `Future<SimApiHttpResponse>`, representing the result of the simulated GET operation.
  Future<SimApiHttpResponse> get(Uri url, {Map<String, String>? headers});

  /// Simulates a PUT request
  ///
  /// [url] The API route (should include the resource ID)
  /// [body] The updated resource data
  /// [headers] Optional headers for the request
  ///
  /// Returns a `Future<SimApiHttpResponse>`, representing the result of the simulated PUT operation.
  Future<SimApiHttpResponse> put(Uri url,
      {Map<String, String>? headers, Object? body});

  /// Simulates a PATCH request
  ///
  /// [url] The API route (should include the resource ID)
  /// [body] The partial update data
  /// [headers] Optional headers for the request
  ///
  /// Returns a `Future<SimApiHttpResponse>`, representing the result of the simulated PATCH operation.
  Future<SimApiHttpResponse> patch(Uri url,
      {Map<String, String>? headers, Object? body});

  /// Simulates a DELETE request
  ///
  /// [url] The API route (should include the resource ID)
  /// [headers] Optional headers for the request
  ///
  /// Returns a `Future<SimApiHttpResponse>`, representing the result of the simulated DELETE operation.
  Future<SimApiHttpResponse> delete(Uri url,
      {Map<String, String>? headers, Object? body});

  /// Seeds the sim api with initial data
  ///
  /// [route] The API route to seed
  /// [data] The initial data to seed, where the key is the resource ID and the value is the resource data.
  ///
  /// This method is useful for initializing the sim api with predefined data.
  void seedData(String route, Map<TId, dynamic> data);

  /// Clears all data from the sim api
  ///
  /// This method is useful for resetting the sim api to an empty state.
  void clearData();

  /// Retrieves the current state of the sim api's data
  ///
  /// This method is primarily for debugging and testing purposes.
  /// Returns a `Map<String, Map<TId, dynamic>>` where the key is the route and the value is the map of resources for that route.
  Map<String, Map<TId, dynamic>> get currentData;

  /// Sets the delay for simulated network operations
  ///
  /// [milliseconds] The delay in milliseconds
  ///
  /// This method allows you to simulate network latency.
  set delay(int milliseconds);

  /// Retrieves the current delay setting
  ///
  /// Returns the current delay in milliseconds.
  int get delay;

  /// Registers a route with optional configuration for handling requests.
  ///
  /// - **route**: The API route to register.
  /// - **method**: Optional. The HTTP method to associate with the route (e.g., GET, POST, PUT, DELETE). If not provided, a default method will be used.
  /// - **haveRouteParameters**: Optional. Indicates if the route includes dynamic route parameters (e.g., `/items/{id}`). Defaults to `false`.
  /// - **haveQueryParameters**: Optional. Indicates if the route includes query parameters. Defaults to `false`.
  /// - **handler**: Optional. A function to handle requests to this route, allowing customization of the response based on request data and query parameters.
  ///
  /// This method allows for detailed configuration of a route, including HTTP method, route parameters, and custom request handling.
  SimApiBase registerRoute(
    String route, {
    SimApiHttpMethod? method,
    bool? haveRouteParameters,
    bool? haveQueryParameters,
    RouteHandler? handler,
  });

  /// Registers a route with a specified HTTP method
  ///
  /// [route] The API route to register
  /// [method] The HTTP method to associate with the route (e.g., GET, POST, PUT, DELETE)
  ///
  /// This method allows you to define a route and its associated HTTP method for handling requests.
  SimApiBase registerRouteWithMethod(String route, SimApiHttpMethod method);
}
