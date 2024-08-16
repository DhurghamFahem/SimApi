import 'dart:convert';
import 'dart:math';

import 'package:sim_api/models/sim_api_exception.dart';

class IdGenerator<TId> {
  final Random _random = Random.secure();

  /// Generates a new ID based on the maximum existing ID.
  ///
  /// - **maxId**: The maximum ID currently in use. This is used to generate the next integer ID if `TId` is `int`.
  ///
  /// **Returns**:
  /// - A new ID of type `TId`. If `TId` is `String`, a random string is generated. If `TId` is `int`, the ID is `maxId + 1`.
  ///
  /// **Throws**:
  /// - `SimApiException` if `TId` is not supported (i.e., neither `String` nor `int`).
  TId generate(int maxId) {
    if (TId == String) {
      return _generateRandomString() as TId;
    } else if (TId == int) {
      return (maxId + 1) as TId;
    } else {
      throw SimApiException('Unsupported ID type: ${TId.toString()}');
    }
  }

  /// Generates a random string ID.
  ///
  /// **Returns**:
  /// - A random string of length 8 encoded in base64 URL format.
  String _generateRandomString() {
    const length = 8;
    final values = List<int>.generate(length, (i) => _random.nextInt(255));
    return base64Url.encode(values).substring(0, length);
  }
}
