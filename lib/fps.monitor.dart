import 'package:demo_project/fps.controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FPSMonitor extends StatefulWidget {
  const FPSMonitor({super.key});

  @override
  State<FPSMonitor> createState() => _FPSMonitorState();
}

class _FPSMonitorState extends State<FPSMonitor> {
  double _fps = 0.0;
  int _frameCount = 0;
  Duration _lastTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onReportTimings);
  }

  void _onReportTimings(List<FrameTiming> timings) {
    if (!mounted) return;

    final now = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
    _frameCount += timings.length;

    if (_lastTime == Duration.zero) {
      _lastTime = now;
      return;
    }

    final duration = now - _lastTime;
    if (duration.inMilliseconds > 1000) {
      // Update every second
      setState(() {
        _fps = (_frameCount * 1000) / duration.inMilliseconds;
        _frameCount = 0;
        _lastTime = now;
      });
    }
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onReportTimings);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'FPS: ${_fps.toStringAsFixed(1)}',
          style: TextStyle(
            color: _fps < 30
                ? Colors.red
                : _fps < 60
                    ? Colors.green
                    : Colors.orange,
            fontSize: 30,
          ),
        ),
        Expanded(
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Target FPS: ${FPSController.currentFPS.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 30),
                  ),
                  Text(
                    'FPS: ${_fps.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _fps < 30
                          ? Colors.red
                          : _fps < 60
                              ? Colors.green
                              : Colors.amber,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
