class SimApiDataStorage<TId> {
  final Map<String, Map<TId, dynamic>> _data = {};

  /// Stores a value for a given route and ID.
  ///
  /// - **route**: The route where the value should be stored.
  /// - **id**: The ID associated with the value.
  /// - **value**: The value to be stored.
  void set(String route, TId id, dynamic value) {
    value['id'] = id.toString();
    _data.putIfAbsent(route, () => {})[id] = value;
  }

  /// Retrieves a value for a given route and ID.
  ///
  /// - **route**: The route from which the value should be retrieved.
  /// - **id**: The ID associated with the value.
  ///
  /// **Returns**:
  /// - The value associated with the route and ID, or `null` if not found.
  dynamic get(String route, TId id) {
    return _data[route]?[id];
  }

  /// Retrieves all values for a given route.
  ///
  /// - **route**: The route for which all values should be retrieved.
  ///
  /// **Returns**:
  /// - A list of values associated with the route, or an empty list if no values are found.
  List<dynamic> getAll(String route) {
    return _data[route]?.values.toList() ?? [];
  }

  /// Retrieves the map of values for a given route.
  ///
  /// - **route**: The route for which the map of values should be retrieved.
  ///
  /// **Returns**:
  /// - A map of ID-value pairs for the route, or `null` if no values are found.
  Map<TId, dynamic>? getMap(String route) {
    return _data[route];
  }

  /// Updates a value for a given route and ID.
  ///
  /// - **route**: The route where the value should be updated.
  /// - **id**: The ID associated with the value.
  /// - **value**: The new value to be set.
  ///
  /// **Returns**:
  /// - `true` if the value was updated successfully, or `false` if the route or ID was not found.
  bool update(String route, TId id, dynamic value) {
    if (_data.containsKey(route) && _data[route]!.containsKey(id)) {
      value['id'] = id.toString();
      _data[route]![id] = value;
      return true;
    }
    return false;
  }

  /// Partially updates a value for a given route and ID.
  ///
  /// - **route**: The route where the value should be partially updated.
  /// - **id**: The ID associated with the value.
  /// - **updates**: A map of updates to be applied to the existing value.
  ///
  /// **Returns**:
  /// - `true` if the value was partially updated successfully, or `false` if the route, ID, or value type was not suitable.
  bool patch(String route, TId id, Map<String, dynamic> updates) {
    if (_data.containsKey(route) && _data[route]!.containsKey(id)) {
      if (_data[route]![id] is Map) {
        (_data[route]![id] as Map<String, dynamic>).addAll(updates);
        return true;
      }
    }
    return false;
  }

  /// Removes a value for a given route and ID.
  ///
  /// - **route**: The route from which the value should be removed.
  /// - **id**: The ID associated with the value.
  void remove(String route, TId id) {
    if (_data.containsKey(route)) {
      _data[route]!.remove(id);
      if (_data[route]!.isEmpty) {
        _data.remove(route);
      }
    }
  }

  /// Checks if a value exists for a given route and ID.
  ///
  /// - **route**: The route to check.
  /// - **id**: The ID to check.
  ///
  /// **Returns**:
  /// - `true` if the value exists, or `false` if it does not.
  bool exists(String route, TId id) {
    return _data[route]?.containsKey(id) ?? false;
  }

  /// Checks if any data exists for a given route.
  ///
  /// - **route**: The route to check.
  ///
  /// **Returns**:
  /// - `true` if the route exists, or `false` if it does not.
  bool routeExists(String route) {
    return _data.containsKey(route);
  }

  /// Retrieves all data for a given route that matches the query.
  ///
  /// - **route**: The route for which data should be queried.
  /// - **queryParams**: A map of query parameters to match against the data.
  ///
  /// **Returns**:
  /// - A list of values that match the query parameters.
  List<dynamic> query(String route, Map<String, dynamic> queryParams) {
    final routeData = _data[route];
    if (routeData == null) return [];

    return routeData.values.where((item) {
      if (item is Map) {
        return queryParams.entries
            .every((entry) => item[entry.key] == entry.value);
      }
      return false;
    }).toList();
  }

  /// Retrieves the maximum ID value for the given data.
  ///
  /// **Returns**:
  /// - The maximum ID value found in the data, or `0` if IDs are of type `String`.
  int getMaxId() {
    if (TId is String) {
      return 0;
    }
    return _data.values
        .expand((routeData) => routeData.keys.whereType<int>())
        .fold(0, (max, id) => id > max ? id : max);
  }

  /// Seeds initial data for a given route.
  ///
  /// - **route**: The route to seed with initial data.
  /// - **data**: A map of ID-value pairs to be seeded.
  void seed(String route, Map<TId, dynamic> data) {
    _data[route] = Map.from(data);
  }

  /// Clears all data.
  void clear() {
    _data.clear();
  }

  /// Returns a copy of the internal data structure.
  ///
  /// **Returns**:
  /// - A copy of the map containing all data for each route.
  Map<String, Map<TId, dynamic>> get data => Map.from(_data);
}
