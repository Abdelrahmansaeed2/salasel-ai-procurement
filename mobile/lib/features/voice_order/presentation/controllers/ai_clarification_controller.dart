import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../orders/presentation/screens/order_review_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiClarificationController extends GetxController {
  final textController = TextEditingController();
  final messages = <ChatMessage>[].obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    messages.add(ChatMessage(
      text: 'أحتاج طماطم وبصل لفرع الرياض',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ));
    messages.add(ChatMessage(
      text: 'عفواً، كم كمية الطماطم التي تحتاجها؟',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    textController.clear();

    _processReply();
  }

  void recordVoice() {
    messages.add(ChatMessage(
      text: '(رسالة صوتية) ٥٠ كيلو طماطم',
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _processReply();
  }

  void _processReply() {
    isProcessing.value = true;
    
    Future.delayed(const Duration(seconds: 2), () {
      isProcessing.value = false;
      
      messages.add(ChatMessage(
        text: 'ممتاز! جاري تجهيز الطلب بالكميات المحددة...',
        isUser: false,
        timestamp: DateTime.now(),
      ));

      Future.delayed(const Duration(seconds: 1), () {
        Get.off(
          () => const OrderReviewScreen(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 350),
        );
      });
    });
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
