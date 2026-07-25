import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

class VoiceRecordingController extends GetxController {
  final RxBool isRecording = false.obs;
  final RxList<double> waveform = <double>[
    for (int i = 0; i < 32; i++) 0.2,
  ].obs;

  Timer? _waveTimer;
  final _random = Random();

  void startRecording() {
    isRecording.value = true;
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      waveform.value = [
        for (int i = 0; i < 32; i++) 0.15 + _random.nextDouble() * 0.85,
      ];
    });
  }

  void stopRecording() {
    isRecording.value = false;
    _waveTimer?.cancel();
    waveform.value = [for (int i = 0; i < 32; i++) 0.2];
  }

  @override
  void onClose() {
    _waveTimer?.cancel();
    super.onClose();
  }
}
