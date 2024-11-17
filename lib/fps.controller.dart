// import 'dart:developer';
// import 'package:flutter/scheduler.dart';

// class FPSController {
//   static int _targetFPS = 60;
//   static bool _isInitialized = false;
//   static Duration _targetFrameDuration = Duration.zero;
//   static int _lastFrameTime = 0;

//   static int get currentFPS => _targetFPS;
//   static bool get isInitialized => _isInitialized;

//   static void setFPS(int targetFPS) {
//     try {
//       _targetFPS = targetFPS;
//       _targetFrameDuration = Duration(microseconds: (1000000 ~/ targetFPS));

//       // Remove existing callback if any
//       if (_isInitialized) {
//         SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
//       }

//       // Add frame timing callback
//       SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
//       _lastFrameTime = DateTime.now().microsecondsSinceEpoch;
//       _isInitialized = true;
//     } catch (e) {
//       log('Failed to set FPS: $e');
//       _isInitialized = false;
//     }
//   }

//   static void _onFrameTimings(List<FrameTiming> timings) {
//     if (!_isInitialized) return;

//     final now = DateTime.now().microsecondsSinceEpoch;
//     final elapsed = now - _lastFrameTime;
//     final targetMicros = _targetFrameDuration.inMicroseconds;

//     if (elapsed >= targetMicros) {
//       // Time to render next frame
//       SchedulerBinding.instance.scheduleFrame();
//       _lastFrameTime = now;
//     } else {
//       // Wait for the remaining time before scheduling next frame
//       Future.delayed(
//         Duration(microseconds: targetMicros - elapsed),
//         () {
//           if (_isInitialized) {
//             SchedulerBinding.instance.scheduleFrame();
//             _lastFrameTime = DateTime.now().microsecondsSinceEpoch;
//           }
//         },
//       );
//     }
//   }

//   static void initialize({int? defaultFPS}) {
//     setFPS(defaultFPS ?? 30);
//   }

//   static void dispose() {
//     if (_isInitialized) {
//       SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
//       _isInitialized = false;
//     }
//   }
// }

import 'dart:developer';
import 'package:flutter/scheduler.dart';

class FPSLimiter {
  static const int maxFps = 30; // Strict 30 FPS cap
  static bool _isInitialized = false;
  static const Duration _frameTime =
      Duration(microseconds: (1000000 ~/ maxFps));
  static int _lastFrameTime = 0;
  static bool _frameScheduled = false;

  static bool get isInitialized => _isInitialized;
  static int get targetFPS => maxFps;

  static void initialize() {
    if (!_isInitialized) {
      try {
        SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
        _lastFrameTime = DateTime.now().microsecondsSinceEpoch;
        _isInitialized = true;
        log('FPS Limiter initialized at $maxFps FPS');
      } catch (e) {
        log('Failed to initialize FPS Limiter: $e');
        _isInitialized = false;
      }
    }
  }

  static void _onFrameTimings(List<FrameTiming> timings) {
    if (!_isInitialized) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    final elapsed = now - _lastFrameTime;
    final targetMicros = _frameTime.inMicroseconds;

    if (elapsed >= targetMicros && !_frameScheduled) {
      _frameScheduled = true;

      // Schedule next frame with precise timing
      Future.delayed(
        Duration.zero,
        () {
          if (_isInitialized) {
            SchedulerBinding.instance.scheduleFrame();
            _lastFrameTime = DateTime.now().microsecondsSinceEpoch;
            _frameScheduled = false;
          }
        },
      );
    }
  }

  static void dispose() {
    if (_isInitialized) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
      _isInitialized = false;
      _frameScheduled = false;
      log('FPS Limiter disposed');
    }
  }
}
