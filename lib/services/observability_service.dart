import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class ObservabilityService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  static Future<void> setUser(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  static Future<void> clearUser() async {
    await _crashlytics.setUserIdentifier('');
  }

  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    await _crashlytics.recordError(exception, stack, reason: reason ?? '');
    debugPrint('🔥 Crashlytics: $exception');
  }

  static void log(String message) {
    _crashlytics.log(message);
  }

  static Future<Trace> startTrace(String name) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    return trace;
  }

  static Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }
}
