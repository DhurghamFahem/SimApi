library sim_api;

import 'package:http/http.dart';
import 'package:sim_api/models/sim_api_exception.dart';
import 'package:sim_api/models/sim_api_http_method.dart';
import 'package:sim_api/models/sim_api_http_response.dart';
import 'package:sim_api/models/sim_api_route_config.dart';
import 'package:sim_api/services/delay_service.dart';
import 'package:sim_api/services/id_extractor.dart';
import 'package:sim_api/services/id_generator.dart';
import 'package:sim_api/sim_api_base.dart';
import 'package:sim_api/storage/sim_api_data_storage.dart';
import 'package:sim_api/storage/sim_api_route_storage.dart';
import 'package:sim_api/typedefs/route_handler.dart';

class SimApi<TId> implements SimApiBase<TId> {
  final DelayService _delayService;
  final IdGenerator<TId> _idGenerator;
  final IdExtractor<TId> _idExtractor;
  final SimApiDataStorage<TId> _dataStorage;
  final SimApiRouteStorage _routeStorage;

  SimApi({int defaultDelay = 500})
      : _delayService = DelayService(defaultDelay: defaultDelay),
        _idGenerator = IdGenerator<TId>(),
        _idExtractor = IdExtractor<TId>(),
        _dataStorage = SimApiDataStorage<TId>(),
        _routeStorage = SimApiRouteStorage();

  /// Handles POST requests by storing new data in the sim api.
  ///
  /// - **url**: The URI representing the API endpoint where the request is being sent.
  /// - **headers**: Optional headers for the request, provided as a map of key-value pairs.
  /// - **body**: The request body, containing the data to be stored. This can be of any type.
  ///
  /// **Process**:
  /// 1. Extracts the base route from the URL.
  /// 2. Checks if the route is registered and allows POST requests.
  /// 3. If a custom handler is provided for the route, it executes the handler and returns the response.
  /// 4. Simulates a network delay using `_delayService`.
  /// 5. Generates a new ID for the resource using `_idGenerator`.
  /// 6. Stores the data in `_dataStorage` with the generated ID.
  /// 7. Returns a `SimApiHttpResponse.created` response with the new ID.
  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    final parsedUrl = url.toString();
    final route = _routeStorage.getBaseRoute(parsedUrl);
    if (route == null) {
      throw SimApiException.routeIsNotRegistered(parsedUrl);
    }
    final routeConfig = _routeStorage.getRouteConfig(route);
    if (routeConfig != null &&
        routeConfig.method != null &&
        routeConfig.method != SimApiHttpMethod.post) {
      return SimApiHttpResponse.methodNotAllowed();
    }
    if (routeConfig?.handler != null) {
      return _getRouteHandler(routeConfig, url, headers, body);
    }
    await _delayService.simulateDelay();
    final id = _idGenerator.generate(_dataStorage.getMaxId());
    _dataStorage.set(url.toString(), id, body);
    return SimApiHttpResponse.created(id);
  }

  /// Handles GET requests by retrieving data from the sim api.
  ///
  /// - **url**: The URI representing the API endpoint where the request is being sent.
  /// - **headers**: Optional headers for the request, provided as a map of key-value pairs.
  ///
  /// **Process**:
  /// 1. Extracts the base route from the URL.
  /// 2. Checks if the route is registered and allows GET requests.
  /// 3. If a custom handler is provided for the route, it executes the handler and returns the response.
  /// 4. Simulates a network delay using `_delayService`.
  /// 5. Retrieves the data from `_dataStorage` based on the route and optional ID extracted from the URL.
  /// 6. If an ID is provided and exists, returns the corresponding resource.
  /// 7. If no ID is provided, returns a list of all resources, optionally filtered by query parameters.
  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    final parsedUrl = url.toString();
    final route = _routeStorage.getBaseRoute(parsedUrl);
    if (route == null) {
      throw SimApiException.routeIsNotRegistered(parsedUrl);
    }
    final routeConfig = _routeStorage.getRouteConfig(route);
    if (routeConfig != null &&
        routeConfig.method != null &&
        routeConfig.method != SimApiHttpMethod.get) {
      return SimApiHttpResponse.methodNotAllowed();
    }
    if (routeConfig?.handler != null) {
      return _getRouteHandler(routeConfig, url, headers, null);
    }
    await _delayService.simulateDelay();
    final routeData = _dataStorage.getMap(route);
    final id = _idExtractor.extract(route, parsedUrl);
    if (id != null) {
      final data = routeData?[id];
      return data != null
          ? SimApiHttpResponse.ok(data)
          : SimApiHttpResponse.notFound();
    }

    var dataList = routeData?.values.toList() ?? [];
    final query = url.queryParameters;
    if (query.isNotEmpty) {
      dataList = dataList.where((item) {
        return item is Map &&
            query.entries.every((entry) => item[entry.key] == entry.value);
      }).toList();
    }
    return SimApiHttpResponse.ok(dataList);
  }

  /// Handles PUT requests by updating existing data in the sim api.
  ///
  /// - **url**: The URI representing the API endpoint where the request is being sent, including the resource ID.
  /// - **headers**: Optional headers for the request, provided as a map of key-value pairs.
  /// - **body**: The request body, containing the updated data. This can be of any type.
  ///
  /// **Process**:
  /// 1. Extracts the base route from the URL.
  /// 2. Checks if the route is registered and allows PUT requests.
  /// 3. If a custom handler is provided for the route, it executes the handler and returns the response.
  /// 4. Simulates a network delay using `_delayService`.
  /// 5. Extracts the resource ID from the URL.
  /// 6. If the ID exists, updates the resource in `_dataStorage` with the new data.
  /// 7. If the ID does not exist, calls `post` to create a new resource.
  /// 8. Returns a `SimApiHttpResponse.ok` response with the updated data.
  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    final parsedUrl = url.toString();
    final route = _routeStorage.getBaseRoute(parsedUrl);
    if (route == null) {
      throw SimApiException.routeIsNotRegistered(parsedUrl);
    }
    final routeConfig = _routeStorage.getRouteConfig(route);
    if (routeConfig != null &&
        routeConfig.method != null &&
        routeConfig.method != SimApiHttpMethod.put) {
      return SimApiHttpResponse.methodNotAllowed();
    }
    if (routeConfig?.handler != null) {
      return _getRouteHandler(routeConfig, url, headers, body);
    }
    await _delayService.simulateDelay();
    final id = _idExtractor.extract(route, parsedUrl);
    if (id == null || !_dataStorage.exists(route, id)) {
      return post(url, headers: headers, body: body);
    }
    final result = _dataStorage.update(route, id, body);
    if (!result) {
      throw SimApiException.unKown();
    }
    return SimApiHttpResponse.ok(_dataStorage.get(route, id));
  }

  /// Handles PATCH requests by partially updating existing data in the sim api.
  ///
  /// - **url**: The URI representing the API endpoint where the request is being sent, including the resource ID.
  /// - **headers**: Optional headers for the request, provided as a map of key-value pairs.
  /// - **body**: The request body, containing the partial update data. This can be of any type.
  ///
  /// **Process**:
  /// 1. Extracts the base route from the URL.
  /// 2. Checks if the route is registered and allows PATCH requests.
  /// 3. If a custom handler is provided for the route, it executes the handler and returns the response.
  /// 4. Simulates a network delay using `_delayService`.
  /// 5. Extracts the resource ID from the URL.
  /// 6. If the ID exists, updates the resource in `_dataStorage` with the partial data.
  /// 7. If the ID does not exist, returns a `SimApiHttpResponse.notFound`.
  /// 8. Returns a `SimApiHttpResponse.ok` response with the updated data.
  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    final parsedUrl = url.toString();
    final route = _routeStorage.getBaseRoute(parsedUrl);
    if (route == null) {
      throw SimApiException.routeIsNotRegistered(parsedUrl);
    }
    final routeConfig = _routeStorage.getRouteConfig(route);
    if (routeConfig != null &&
        routeConfig.method != null &&
        routeConfig.method != SimApiHttpMethod.patch) {
      return SimApiHttpResponse.methodNotAllowed();
    }
    if (routeConfig?.handler != null) {
      return _getRouteHandler(routeConfig, url, headers, body);
    }
    await _delayService.simulateDelay();
    final id = _idExtractor.extract(route, parsedUrl);
    if (id == null || !_dataStorage.exists(route, id)) {
      return SimApiHttpResponse.notFound();
    }
    final result = _dataStorage.update(route, id, body);
    if (!result) {
      throw SimApiException.unKown();
    }
    final data = _dataStorage.get(route, id);
    return SimApiHttpResponse.ok(data);
  }

  /// Handles DELETE requests by removing data from the sim api.
  ///
  /// - **url**: The URI representing the API endpoint where the request is being sent, including the resource ID.
  /// - **headers**: Optional headers for the request, provided as a map of key-value pairs.
  /// - **body**: Optional request body, typically not used in DELETE requests but included for completeness.
  ///
  /// **Process**:
  /// 1. Extracts the base route from the URL.
  /// 2. Checks if the route is registered and allows DELETE requests.
  /// 3. If a custom handler is provided for the route, it executes the handler and returns the response.
  /// 4. Simulates a network delay using `_delayService`.
  /// 5. Extracts the resource ID from the URL.
  /// 6. If the ID exists, removes the resource from `_dataStorage`.
  /// 7. If the ID does not exist, returns a `SimApiHttpResponse.noContent` response.
  /// 8. Returns a `SimApiHttpResponse.noContent` response indicating successful deletion.
  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    final parsedUrl = url.toString();
    final route = _routeStorage.getBaseRoute(parsedUrl);
    if (route == null) {
      throw SimApiException.routeIsNotRegistered(parsedUrl);
    }
    final routeConfig = _routeStorage.getRouteConfig(route);
    if (routeConfig != null &&
        routeConfig.method != null &&
        routeConfig.method != SimApiHttpMethod.delete) {
      return SimApiHttpResponse.methodNotAllowed();
    }
    if (routeConfig?.handler != null) {
      return _getRouteHandler(routeConfig, url, headers, body);
    }
    await _delayService.simulateDelay();
    final id = _idExtractor.extract(route, parsedUrl);
    if (id == null || !_dataStorage.exists(route, id)) {
      return SimApiHttpResponse.noContent();
    }
    _dataStorage.remove(route, id);
    return SimApiHttpResponse.noContent();
  }

  /// Gets the current delay time for simulating network latency.
  ///
  /// **Returns**:
  /// - The delay time in milliseconds.
  @override
  int get delay => _delayService.defaultDelay;

  /// Clears all data stored in the sim api.
  ///
  /// **Process**:
  /// - Invokes the `clear` method on `_dataStorage` to remove all stored data.
  @override
  void clearData() {
    _dataStorage.clear();
  }

  /// Retrieves the current data stored in the sim api.
  ///
  /// **Returns**:
  /// - A map where each key is a route, and each value is a map of resource IDs to data.
  @override
  Map<String, Map<TId, dynamic>> get currentData => _dataStorage.data;

  /// Seeds the sim api with initial data for a specific route.
  ///
  /// - **route**: The route to which the data should be added.
  /// - **data**: A map of resource IDs to data for the specified route.
  ///
  /// **Process**:
  /// - Invokes the `seed` method on `_dataStorage` to add the initial data.
  @override
  void seedData(String route, Map<TId, dynamic> data) {
    _dataStorage.seed(route, data);
  }

  /// Sets a new delay time for simulating network latency.
  ///
  /// - **milliseconds**: The new delay time in milliseconds.
  ///
  /// **Process**:
  /// - Invokes the `setDelay` method on `_delayService` to update the delay time.
  @override
  set delay(int milliseconds) {
    _delayService.setDelay(milliseconds);
  }

  /// Registers a new route with optional configuration.
  ///
  /// - **route**: The API route to register.
  /// - **method**: Optional. The HTTP method to associate with the route (e.g., GET, POST, PUT, DELETE). If not provided, a default method will be used.
  /// - **haveRouteParameters**: Optional. Indicates if the route includes dynamic route parameters (e.g., `/items/{id}`). Defaults to `false` if not specified.
  /// - **haveQueryParameters**: Optional. Indicates if the route includes query parameters. Defaults to `false` if not specified.
  /// - **handler**: Optional. A function to handle requests to this route, allowing customization of the response based on request data and query parameters.
  ///
  /// **Returns**:
  /// - The current instance of `SimApiBase` to allow method chaining.
  ///
  /// This method registers a route with customizable configuration, including HTTP method, route parameters, query parameters, and a custom handler function.
  @override
  SimApiBase registerRoute(
    String route, {
    SimApiHttpMethod? method,
    bool? haveRouteParameters,
    bool? haveQueryParameters,
    RouteHandler? handler,
  }) {
    _routeStorage.registerRoute(route,
        routeConfig: SimApiRouteConfig(
          method: method,
          haveRouteParameters: haveRouteParameters ?? false,
          haveQueryParameters: haveQueryParameters ?? false,
          handler: handler,
        ));
    return this;
  }

  /// Registers a new route with a specified HTTP method.
  ///
  /// - **route**: The route to be registered.
  /// - **method**: The HTTP method to associate with the route (e.g., GET, POST, PUT, DELETE).
  ///
  /// **Returns**:
  /// - The current instance of `SimApiBase` to allow method chaining.
  ///
  /// This method registers a route with a predefined HTTP method, setting up the route configuration with the provided method.
  @override
  SimApiBase registerRouteWithMethod(String route, SimApiHttpMethod method) {
    _routeStorage.registerRoute(route,
        routeConfig: SimApiRouteConfig(method: method));
    return this;
  }

  Future<Response> _getRouteHandler(SimApiRouteConfig? routeConfig, Uri url,
      Map<String, String>? headers, Object? body) {
    return routeConfig!.handler!(
      url,
      headers: headers,
      body: body,
      post: (url, {body, headers}) => post(
        url,
        body: body,
        headers: headers,
      ),
      get: (url, {body, headers}) => get(
        url,
        headers: headers,
      ),
      put: (url, {body, headers}) => put(
        url,
        body: body,
        headers: headers,
      ),
      patch: (url, {body, headers}) => patch(
        url,
        body: body,
        headers: headers,
      ),
      delete: (url, {body, headers}) => delete(
        url,
        body: body,
        headers: headers,
      ),
    );
  }
}
