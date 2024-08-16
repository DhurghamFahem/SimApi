import 'package:sim_api/models/sim_api_route_config.dart';

class SimApiRouteStorage {
  final Map<String, SimApiRouteConfig?> _routes = {};

  /// Registers a new route with optional configuration.
  ///
  /// - **route**: The route to be registered. This can include a route parameter placeholder (e.g., `"/items/{id}"`).
  /// - **routeConfig**: Optional configuration for the route, which may include allowed methods and a custom handler.
  ///   - If `routeConfig` is provided and has route parameters, the route will be registered with a placeholder `{id}`.
  ///   - Otherwise, the route is registered as-is.
  void registerRoute(String route, {SimApiRouteConfig? routeConfig}) {
    if (routeConfig != null && routeConfig.haveRouteParameters) {
      _routes["$route/{id}"] = routeConfig;
    } else {
      _routes[route] = routeConfig;
    }
  }

  /// Retrieves the base route for a given route.
  ///
  /// - **route**: The full route to be checked, which may include route parameters or query parameters.
  ///
  /// **Returns**:
  /// - The base route if it exists and is registered, or `null` if no matching base route is found.
  ///
  /// **Process**:
  /// 1. Checks if the exact route is registered.
  /// 2. If not, attempts to find a base route by removing route parameters.
  /// 3. If still not found, checks if the route has query parameters and tries to find a base route without them.
  String? getBaseRoute(String route) {
    final isRouteExist = _routes.containsKey(route);
    if (isRouteExist) {
      return route;
    }
    final baseRouteIfTheRouteHaveRouteParameters =
        _getBaseRouteIfTheRouteHasRouteParameters(route);
    if (baseRouteIfTheRouteHaveRouteParameters != null) {
      return baseRouteIfTheRouteHaveRouteParameters;
    }
    final baseRouteIfTheRouteHaveQueryParameters =
        _getBaseRouteIfTheRouteHasQueryParameters(route);
    if (baseRouteIfTheRouteHaveQueryParameters != null) {
      return baseRouteIfTheRouteHaveQueryParameters;
    }
    return null;
  }

  /// Retrieves the configuration for a given route.
  ///
  /// - **route**: The route for which the configuration is to be retrieved.
  ///
  /// **Returns**:
  /// - The `SimApiRouteConfig` associated with the route, or `null` if no configuration is found.
  SimApiRouteConfig? getRouteConfig(String route) {
    return _routes[route];
  }

  /// Helper method to find the base route if the given route includes route parameters.
  ///
  /// - **route**: The route that may contain route parameters.
  ///
  /// **Returns**:
  /// - The base route without route parameters if found, or `null` if no matching base route is found.
  String? _getBaseRouteIfTheRouteHasRouteParameters(String route) {
    final segments = route.split('/');
    if (segments.isEmpty) return null;
    final routeWithoutId = segments.sublist(0, segments.length - 1).join('/');
    final newRoute = "$routeWithoutId/{id}";
    final routeConfig = _routes[newRoute];
    if (routeConfig == null || routeConfig.haveRouteParameters == false) {
      return null;
    }
    return _routes.containsKey(newRoute) ? routeWithoutId : null;
  }

  /// Helper method to find the base route if the given route includes query parameters.
  ///
  /// - **route**: The route that may include query parameters.
  ///
  /// **Returns**:
  /// - The base route without query parameters if found, or `null` if no matching base route is found.
  String? _getBaseRouteIfTheRouteHasQueryParameters(String route) {
    final queryIndex = route.indexOf('?');
    if (queryIndex != -1) {
      final baseRoute = route.substring(0, queryIndex);
      return _routes.containsKey(baseRoute) ? baseRoute : null;
    }
    return _routes.containsKey(route) ? route : null;
  }
}
