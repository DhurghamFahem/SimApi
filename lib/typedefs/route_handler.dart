import 'package:http/http.dart';

typedef RouteHandler = Future<Response> Function(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  required Future<Response> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) post,
  required Future<Response> Function(
    Uri url, {
    Map<String, String>? headers,
  }) get,
  required Future<Response> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) put,
  required Future<Response> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) patch,
  required Future<Response> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) delete,
});
