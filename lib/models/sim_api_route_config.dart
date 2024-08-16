import 'package:sim_api/models/sim_api_http_method.dart';
import 'package:sim_api/models/sim_api_http_response.dart';

class SimApiRouteConfig {
  final SimApiHttpMethod? method;
  final SimApiHttpResponse Function(List<dynamic>, Map<String, String>?)?
      handler;
  final bool haveRouteParameters;
  final bool haveQueryParameters;

  SimApiRouteConfig({
    required this.method,
    this.handler,
    this.haveRouteParameters = false,
    this.haveQueryParameters = false,
  });
}
