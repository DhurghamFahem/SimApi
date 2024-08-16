import 'package:sim_api/models/sim_api_exception.dart';

class IdExtractor<TId> {
  /// Extracts an ID from a route string.
  ///
  /// **Parameters**:
  /// - `baseRoute`: The base route string, which is to be excluded from the extracted ID.
  /// - `route`: The complete route string from which the ID is to be extracted.
  ///
  /// **Returns**:
  /// - The extracted ID of type `TId`. If `TId` is `String`, the ID is returned as a string. If `TId` is `int`, the last segment is parsed as an integer.
  /// - Returns `null` if the ID segment is empty, or if the route does not contain a valid ID.
  ///
  /// **Throws**:
  /// - `SimApiException` if `TId` is not supported (i.e., neither `String` nor `int`).
  TId? extract(String baseRoute, String route) {
    final segments = route.split('/');
    if (segments.isEmpty) return null;

    // Remove the base route from the segments if it is present.
    final baseSegments = baseRoute.split('/');
    final idSegments = segments.sublist(baseSegments.length);

    // The ID is the last segment.
    final idSegment = idSegments.isNotEmpty ? idSegments.last : null;
    if (idSegment == null || idSegment.isEmpty) return null;

    if (TId == String) {
      return idSegment as TId;
    } else if (TId == int) {
      final id = int.tryParse(idSegment);
      if (id == null) return null;
      return id as TId;
    } else {
      throw SimApiException('Unsupported ID type: ${TId.toString()}');
    }
  }
}
