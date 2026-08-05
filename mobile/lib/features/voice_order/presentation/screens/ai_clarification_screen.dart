import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../controllers/ai_clarification_controller.dart';

class AiClarificationScreen extends StatelessWidget {
  const AiClarificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiClarificationController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AnimatedEntrance(
                  beginOffset: const Offset(0, -0.2),
                  child: _buildHeader(),
                ),
              ),
              Expanded(
                child: _buildChatList(controller),
              ),
              _buildInputArea(controller),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: -1),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 64.h,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            AnimatedPressable(
              borderRadius: BorderRadius.circular(999.r),
              onTap: () => Get.back(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
                child: SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: SvgPicture.string(
                    '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
                    '<path d="M3.825 9L9.425 14.6L8 16L0 8L8 0L9.425 1.4L3.825 7H16V9H3.825Z" fill="black"/></svg>',
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                'استكمال معلومات الطلب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  letterSpacing: -0.4,
                  height: 1.5.h,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 32.w),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(AiClarificationController controller) {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final message = controller.messages[index];
            return _buildMessageBubble(message);
          },
        ));
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Align(
        alignment: message.isUser ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: message.isUser ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16.r).copyWith(
              bottomLeft: message.isUser ? const Radius.circular(0) : null,
              bottomRight: message.isUser ? null : const Radius.circular(0),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser ? Colors.white : Colors.black87,
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(AiClarificationController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Obx(
          () => controller.isProcessing.value
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.h),
                    child: CircularProgressIndicator(
                      color: const Color(0xFF2563EB),
                      strokeWidth: 2.w,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.textController,
                                decoration: InputDecoration(
                                  hintText: 'اكتب أو تحدث هنا...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                            AnimatedPressable(
                              onTap: controller.recordVoice,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: SvgPicture.asset(
                                  'assets/icons/mic_icon.svg',
                                  width: 20.w,
                                  height: 24.h,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF2563EB),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    AnimatedPressable(
                      onTap: controller.sendMessage,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.send, color: Colors.white, size: 20.w),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
