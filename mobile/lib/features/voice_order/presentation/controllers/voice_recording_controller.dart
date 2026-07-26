import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecordingController extends GetxController {
  final RxBool isRecording = false.obs;
  final RxList<double> waveform = <double>[
    for (int i = 0; i < 32; i++) 0.2,
  ].obs;

  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSub;
  String? _audioPath;

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/order_audio.m4a';

        await _audioRecorder.start(
          RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
          path: path,
        );
        isRecording.value = true;
        _startWaveformUpdates();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  void _startWaveformUpdates() {
    _amplitudeSub?.cancel();
    _amplitudeSub = _audioRecorder.onAmplitudeChanged(Duration(milliseconds: 180)).listen((amp) {
      double normalized = (amp.current + 160) / 160;
      if (normalized < 0.1) normalized = 0.1;
      if (normalized > 1.0) normalized = 1.0;
      
      final currentWaveform = waveform.toList();
      currentWaveform.removeAt(0);
      currentWaveform.add(normalized);
      waveform.value = currentWaveform;
    });
  }

  Future<String?> stopRecording() async {
    try {
      _audioPath = await _audioRecorder.stop();
      isRecording.value = false;
      _amplitudeSub?.cancel();
      waveform.value = [for (int i = 0; i < 32; i++) 0.2];
      return _audioPath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  @override
  void onClose() {
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.onClose();
  }
}
