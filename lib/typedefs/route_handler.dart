import 'package:sim_api/models/sim_api_http_response.dart';

typedef RouteHandler = Future<SimApiHttpResponse> Function(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  required Future<SimApiHttpResponse> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) post,
  required Future<SimApiHttpResponse> Function(
    Uri url, {
    Map<String, String>? headers,
  }) get,
  required Future<SimApiHttpResponse> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) put,
  required Future<SimApiHttpResponse> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) patch,
  required Future<SimApiHttpResponse> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) delete,
});
