class PerformanceService {
  static Future<void> measureTime(
      String operation, Future<void> Function() action) async {
    final start = DateTime.now();
    print('⏱️ Starting: $operation');

    await action();

    final end = DateTime.now();
    final duration = end.difference(start).inMilliseconds;
    print('✅ $operation completed in ${duration}ms');

    // Send to analytics (optional)
    await _logPerformance(operation, duration);
  }

  static Future<void> _logPerformance(String operation, int durationMs) async {
    // You can send this to your backend for monitoring
    print('Performance: $operation = ${durationMs}ms');
  }
}
