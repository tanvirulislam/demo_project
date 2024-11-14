import 'dart:developer';
import 'package:flutter/scheduler.dart';

class FPSController {
  static int _targetFPS = 60;
  static bool _isInitialized = false;
  static Duration _targetFrameDuration = Duration.zero;
  static int _lastFrameTime = 0;

  static int get currentFPS => _targetFPS;
  static bool get isInitialized => _isInitialized;

  static void setFPS(int targetFPS) {
    try {
      _targetFPS = targetFPS;
      _targetFrameDuration = Duration(microseconds: (1000000 ~/ targetFPS));

      // Remove existing callback if any
      if (_isInitialized) {
        SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
      }

      // Add frame timing callback
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
      _lastFrameTime = DateTime.now().microsecondsSinceEpoch;
      _isInitialized = true;
    } catch (e) {
      log('Failed to set FPS: $e');
      _isInitialized = false;
    }
  }

  static void _onFrameTimings(List<FrameTiming> timings) {
    if (!_isInitialized) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    final elapsed = now - _lastFrameTime;
    final targetMicros = _targetFrameDuration.inMicroseconds;

    if (elapsed >= targetMicros) {
      // Time to render next frame
      SchedulerBinding.instance.scheduleFrame();
      _lastFrameTime = now;
    } else {
      // Wait for the remaining time before scheduling next frame
      Future.delayed(
        Duration(microseconds: targetMicros - elapsed),
        () {
          if (_isInitialized) {
            SchedulerBinding.instance.scheduleFrame();
            _lastFrameTime = DateTime.now().microsecondsSinceEpoch;
          }
        },
      );
    }
  }

  static void initialize({int defaultFPS = 30}) {
    setFPS(defaultFPS);
  }

  static void dispose() {
    if (_isInitialized) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
      _isInitialized = false;
    }
  }
}
