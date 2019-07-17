import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_recording_arguments.dart';

class AudioRecorder {
  final MethodChannel _channel =
  const MethodChannel('com.sputnikmessenger.sputnik_audio_recorder');

  bool _isRecording = false;
  bool _isPaused = false;
  bool _isDisposed = true;

  bool get isRecording => _isRecording;
  bool get isDisposed => _isDisposed;

  bool get isPaused => _isPaused;

  final String handle;

  AudioRecorder(this.handle);

  Future startRecording(AudioRecordingArguments arguments) async {
    arguments.handle = handle;
    if (!isRecording) {
      _isRecording = true;
      _isDisposed = false;
      await _channel.invokeMethod('startRecording', arguments.toJson());
    }
  }

  Future stopRecording() async {
    await resumeRecording();
    if (isRecording) {
      _isRecording = false;
      await _channel.invokeMethod('stopRecording', {'handle': handle});
    }
  }

  Future pauseRecording() async {
    if (_isRecording && !_isPaused) {
      _isPaused = true;
      await _channel.invokeMethod('pauseRecording', {'handle': handle});
    }
  }

  Future resumeRecording() async {
    if (_isRecording && _isPaused) {
      _isPaused = false;
      await _channel.invokeMethod('resumeRecording', {'handle': handle});
    }
  }

  Future<int> getMaxAmplitude() async {
    int amp = 0;
    if (_isRecording) {
      amp = await _channel
          .invokeMethod<int>('getMaxAmplitude', {'handle': handle});
    }
    return amp;
  }

  void setEventListeners({
    @required void Function() onInfo,
    @required void Function() onError,
    @required void Function() onLimitReached,
  }) {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onInfo':
          onInfo();
          break;
        case 'onError':
          onError();
          break;
        case 'onLimitReached':
          onLimitReached();
          break;
        default:
          debugPrint('Unhandled method ${call.method}');
      }
    });
  }

  Future dispose() async {
    if (!_isDisposed) {
      resumeRecording();
      _isDisposed = true;
      _isRecording = false;
      _isPaused = false;
      await _channel.invokeMethod('disposeRecorder', {'handle': handle});
    }
  }

  Future disposeAll() async {
    _channel.setMethodCallHandler(null);
    await _channel.invokeMethod('disposeAll');
  }
}
