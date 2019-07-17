import 'package:sputnik_audio_recorder/src/audio_channels.dart';
import 'package:sputnik_audio_recorder/src/audio_encoder.dart';
import 'package:sputnik_audio_recorder/src/audio_source.dart';
import 'package:sputnik_audio_recorder/src/output_format.dart';

class AudioRecordingArguments {
  String handle;
  final String outputFile;
  final int audioSource;
  final int outputFormat;
  final int audioEncoder;
  final int audioChannels;
  final int audioEncodingBitRate;
  final int audioSamplingRate;
  final int maxDuration;
  final int maxFileSize;

  AudioRecordingArguments(
    this.outputFile, {
    this.audioSource = AudioSource.MIC,
    this.outputFormat = OutputFormat.AMR_WB,
    this.audioEncoder = AudioEncoder.AMR_WB,
    this.audioChannels = AudioChannels.MONO,
    this.audioEncodingBitRate,
    this.audioSamplingRate,
    this.maxDuration,
    this.maxFileSize,
  });

  Map<String, dynamic> toJson() {
    final args = {
      'outputFile': outputFile,
      'audioSource': audioSource,
      'outputFormat': outputFormat,
      'audioEncoder': audioEncoder,
      'handle': handle,
    };

    if (audioChannels != null) {
      args['audioChannels'] = audioChannels;
    }
    if (audioEncodingBitRate != null) {
      args['audioEncodingBitRate'] = audioEncodingBitRate;
    }
    if (audioSamplingRate != null) {
      args['audioSamplingRate'] = audioSamplingRate;
    }
    if (maxDuration != null) {
      args['maxDuration'] = maxDuration;
    }
    if (maxFileSize != null) {
      args['maxFileSize'] = maxFileSize;
    }
    return args;
  }
}
