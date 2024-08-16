class DelayService {
  int _defaultDelay;

  /// Gets the current default delay for simulated network operations.
  ///
  /// **Returns**:
  /// - The default delay in milliseconds.
  int get defaultDelay => _defaultDelay;

  /// Constructs a `DelayService` instance with an optional default delay.
  ///
  /// **Parameters**:
  /// - `defaultDelay`: The initial default delay in milliseconds. Defaults to 500 milliseconds if not specified.
  DelayService({int defaultDelay = 500}) : _defaultDelay = defaultDelay;

  /// Sets a new delay for simulated network operations.
  ///
  /// **Parameters**:
  /// - `milliseconds`: The new delay duration in milliseconds.
  void setDelay(int milliseconds) {
    _defaultDelay = milliseconds;
  }

  /// Simulates a network delay by waiting for the default delay duration.
  ///
  /// **Returns**:
  /// - A `Future` that completes after the specified delay duration.
  Future<void> simulateDelay() async {
    await Future.delayed(Duration(milliseconds: _defaultDelay));
  }
}
