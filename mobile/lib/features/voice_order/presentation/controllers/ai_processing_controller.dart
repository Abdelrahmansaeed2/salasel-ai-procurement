import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../orders/data/repositories/ai_repository.dart';
import '../../../orders/domain/ai_order_response.dart';
import '../screens/voice_recording_screen.dart';

enum ProcessingStepState { completed, active, pending }

class ProcessingStep {
  final String title;
  final String subtitle;
  ProcessingStep({required this.title, required this.subtitle});
}

class AiProcessingController extends GetxController {
  final List<ProcessingStep> steps = [
    ProcessingStep(title: 'تم استلام الصوت', subtitle: 'تم تسجيل الطلب بنجاح'),
    ProcessingStep(title: 'فهم الطلب...', subtitle: 'تحليل المكونات والكميات'),
    ProcessingStep(title: 'مطابقة المنتجات', subtitle: 'البحث في الكتالوج المتاح'),
    ProcessingStep(title: 'البحث عن أفضل مورد', subtitle: 'تحسين التكلفة والوقت'),
  ];

  final RxInt activeStep = 1.obs;
  final AiRepository _aiRepository = AiRepository();
  final ApiClient _apiClient = ApiClient();
  
  AiOrderResponse? currentResponse;

  Future<void> start(String audioPath, void Function(bool needsClarification) onFinishedCallback) async {
    try {
      // 1. Fetch merchant ID from primary shop
      final shopsResponse = await _apiClient.dio.get('/merchants/me/shops');
      int merchantId = 1; // fallback
      if (shopsResponse.statusCode == 200) {
        final List<dynamic> shops = shopsResponse.data;
        if (shops.isNotEmpty) {
          merchantId = shops.first['merchantID'];
        }
      }

      // Simulate step progression visually while uploading
      activeStep.value = 1;
      Timer? fakeProgressTimer = Timer.periodic(Duration(milliseconds: 1200), (timer) {
        if (activeStep.value < steps.length - 1) {
          activeStep.value++;
        }
      });

      // 2. Upload to AI relay
      final response = await _aiRepository.uploadVoiceOrder(audioPath, merchantId);
      currentResponse = response;
      
      fakeProgressTimer.cancel();
      activeStep.value = steps.length; // all complete

      Future.delayed(Duration(milliseconds: 500), () {
        debugPrint('AI RESPONSE: splits=${response.splits.length}, unresolved=${response.unresolved.length}');
        if (response.unresolved.isEmpty && response.splits.isEmpty) {
          Get.snackbar(
            'لم يتم التعرف على منتجات', 
            'يرجى التحدث بوضوح وتحديد المنتجات المطلوبة.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.9),
            colorText: const Color(0xFFFFFFFF),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.error_outline, color: Colors.white),
          );
          Get.off(() => const VoiceRecordingScreen());
        } else if (response.unresolved.isNotEmpty) {
          // Navigates to chat/clarification
          onFinishedCallback(true);
        } else {
          // Perfect match -> review screen
          onFinishedCallback(false);
        }
      });
    } catch (e) {
      debugPrint('AI Processing error: $e');
      Get.snackbar(
        'خطأ', 
        'فشل في تحليل الصوت. حاول مرة أخرى.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.9),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      Get.off(() => const VoiceRecordingScreen());
    }
  }

  ProcessingStepState stateOf(int index) {
    if (index < activeStep.value) return ProcessingStepState.completed;
    if (index == activeStep.value) return ProcessingStepState.active;
    return ProcessingStepState.pending;
  }
}
