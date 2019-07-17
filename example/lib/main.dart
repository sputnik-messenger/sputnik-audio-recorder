import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sputnik_audio_recorder/sputnik_audio_recorder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String path;
  int maxAmp = 0;

  final AudioRecorder recorder = AudioRecorder('example');

  Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    recorder.dispose();
    super.dispose();
  }

  _startTimer() {
    if (timer == null) {
      timer = Timer.periodic(Duration(milliseconds: 500), (_) async {
        int amp = await recorder.getMaxAmplitude();
        setState(() {
          maxAmp = amp;
        });
      });
    }
  }

  _stopTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  Future requestPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.microphone]);
    }
  }

  Future<String> startRecording() async {
    await requestPermission();

    String result;
    final directory = await getTemporaryDirectory();
    try {
      deleteRecording();
      path = '${directory.path}/test';

      recorder.setEventListeners(
          onInfo: () => debugPrint('info'),
          onError: () => debugPrint('error'),
          onLimitReached: () => setState(() => {}));

      result = await recorder.startRecording(AudioRecordingArguments(
        path,
        maxDuration: Duration(seconds: 20).inMilliseconds,
        maxFileSize: 1000000,
        audioSamplingRate: 32000,
        audioEncodingBitRate: AudioBitRate.MEDIUM_192_kBit_s,
        audioChannels: AudioChannels.MONO,
        audioEncoder: AudioEncoder.AMR_WB,
        outputFormat: OutputFormat.AMR_WB,
        audioSource: AudioSource.MIC,
      ));

      setState(() {});
      _startTimer();
    } on PlatformException catch (e) {
      result = 'Failed to start recording. ${e.message}';
    }

    return result;
  }

  Future<String> stopRecording() async {
    String result;
    try {
      result = await recorder.stopRecording();
      setState(() {});
    } on PlatformException catch (e) {
      result = 'Failed to stop recording. ${e.message}';
    }
    _stopTimer();
    return result;
  }

  Future<String> pauseRecording() async {
    String result;
    try {
      result = await recorder.pauseRecording();
      setState(() {});
    } on PlatformException catch (e) {
      result = 'Failed to pause recording. ${e.message}';
    }
    _stopTimer();
    return result;
  }

  Future<String> resumeRecording() async {
    String result;
    try {
      result = await recorder.resumeRecording();
      setState(() {});
      _startTimer();
    } on PlatformException catch (e) {
      result = 'Failed to resume recording. ${e.message}';
    }
    return result;
  }

  Future<String> playRecording() async {
    AudioPlayer audioPlugin = new AudioPlayer();
    await audioPlugin.play(path, isLocal: true);

    return 'ok';
  }

  Future<String> deleteRecording() async {
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    return 'ok';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('$maxAmp'),
              LinearProgressIndicator(value: maxAmp.toDouble() / 32767),
              Visibility(
                visible: !recorder.isRecording,
                child: OutlineButton.icon(
                    onPressed: startRecording,
                    icon: Icon(Icons.mic),
                    label: Text('Record')),
              ),
              Visibility(
                visible: recorder.isRecording,
                child: OutlineButton.icon(
                    onPressed: stopRecording,
                    icon: Icon(Icons.stop),
                    label: Text('Stop')),
              ),
              Visibility(
                visible: !recorder.isPaused && recorder.isRecording,
                child: OutlineButton.icon(
                    onPressed: pauseRecording,
                    icon: Icon(Icons.pause),
                    label: Text('Pause')),
              ),
              Visibility(
                visible: recorder.isPaused,
                child: OutlineButton.icon(
                    onPressed: resumeRecording,
                    icon: Icon(Icons.mic),
                    label: Text('Resume')),
              ),
              OutlineButton.icon(
                  onPressed: playRecording,
                  icon: Icon(Icons.play_arrow),
                  label: Text('Play')),
              Visibility(
                visible: !recorder.isDisposed,
                child: OutlineButton.icon(
                    onPressed: () {
                      _stopTimer();
                      setState(() {
                        recorder.dispose();
                      });
                    },
                    icon: Icon(Icons.delete_forever),
                    label: Text('Dispose')),
              ),
              OutlineButton.icon(
                  onPressed: () {
                    _stopTimer();
                    recorder.disposeAll();
                  },
                  icon: Icon(Icons.delete_forever),
                  label: Text('Dispose all')),
              OutlineButton.icon(
                  onPressed: () => deleteRecording,
                  icon: Icon(Icons.delete),
                  label: Text('deleteRecording'))
            ],
          ),
        ),
      ),
    );
  }
}
