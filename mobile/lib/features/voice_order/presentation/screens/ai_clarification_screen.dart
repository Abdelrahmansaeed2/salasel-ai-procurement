import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../orders/domain/ai_order_response.dart';
import '../controllers/ai_clarification_controller.dart';

class _Icons {
  static const bell =
      '<svg width="16" height="20" viewBox="0 0 16 20" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M0 17V15H2V8C2 6.61667 2.41667 5.3875 3.25 4.3125C4.08333 3.2375 5.16667 2.53333 6.5 2.2V1.5C6.5 1.08333 6.64583 0.729167 6.9375 0.4375C7.22917 0.145833 7.58333 0 8 0C8.41667 0 8.77083 0.145833 9.0625 0.4375C9.35417 0.729167 9.5 1.08333 9.5 1.5V2.2C10.8333 2.53333 11.9167 3.2375 12.75 4.3125C13.5833 5.3875 14 6.61667 14 8V15H16V17H0ZM8 20C7.45 20 6.97917 19.8042 6.5875 19.4125C6.19583 19.0208 6 18.55 6 18H10C10 18.55 9.80417 19.0208 9.4125 19.4125C9.02083 19.8042 8.55 20 8 20ZM4 15H12V8C12 6.9 11.6083 5.95833 10.825 5.175C10.0417 4.39167 9.1 4 8 4C6.9 4 5.95833 4.39167 5.175 5.175C4.39167 5.95833 4 6.9 4 8V15Z" fill="#434655"/></svg>';

  static const menu =
      '<svg width="42" height="33" viewBox="0 0 42 33" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M8 25V22.1667H34V25H8ZM8 17.9167V15.0833H34V17.9167H8ZM8 10.8333V8H34V10.8333H8Z" fill="#434655"/></svg>';

  static const waveform =
      '<svg width="11" height="15" viewBox="0 0 11 15" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M5.25 9C4.625 9 4.09375 8.78125 3.65625 8.34375C3.21875 7.90625 3 7.375 3 6.75V2.25C3 1.625 3.21875 1.09375 3.65625 0.65625C4.09375 0.21875 4.625 0 5.25 0C5.875 0 6.40625 0.21875 6.84375 0.65625C7.28125 1.09375 7.5 1.625 7.5 2.25V6.75C7.5 7.375 7.28125 7.90625 6.84375 8.34375C6.40625 8.78125 5.875 9 5.25 9ZM4.5 14.25V11.9438C3.2 11.7688 2.125 11.1875 1.275 10.2C0.425 9.2125 0 8.0625 0 6.75H1.5C1.5 7.7875 1.86562 8.67188 2.59687 9.40312C3.32812 10.1344 4.2125 10.5 5.25 10.5C6.2875 10.5 7.17188 10.1344 7.90312 9.40312C8.63437 8.67188 9 7.7875 9 6.75H10.5C10.5 8.0625 10.075 9.2125 9.225 10.2C8.375 11.1875 7.3 11.7688 6 11.9438V14.25H4.5ZM5.25 7.5C5.4625 7.5 5.64062 7.42813 5.78438 7.28438C5.92813 7.14062 6 6.9625 6 6.75V2.25C6 2.0375 5.92813 1.85938 5.78438 1.71563C5.64062 1.57188 5.4625 1.5 5.25 1.5C5.0375 1.5 4.85938 1.57188 4.71562 1.71563C4.57187 1.85938 4.5 2.0375 4.5 2.25V6.75C4.5 6.9625 4.57187 7.14062 4.71562 7.28438C4.85938 7.42813 5.0375 7.5 5.25 7.5Z" fill="white"/></svg>';

  static const checkCircle =
      '<svg width="17" height="17" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M7.16667 12.1667L13.0417 6.29167L11.875 5.125L7.16667 9.83333L4.79167 7.45833L3.625 8.625L7.16667 12.1667ZM8.33333 16.6667C7.18056 16.6667 6.09722 16.4479 5.08333 16.0104C4.06944 15.5729 3.1875 14.9792 2.4375 14.2292C1.6875 13.4792 1.09375 12.5972 0.65625 11.5833C0.21875 10.5694 0 9.48611 0 8.33333C0 7.18056 0.21875 6.09722 0.65625 5.08333C1.09375 4.06944 1.6875 3.1875 2.4375 2.4375C3.1875 1.6875 4.06944 1.09375 5.08333 0.65625C6.09722 0.21875 7.18056 0 8.33333 0C9.48611 0 10.5694 0.21875 11.5833 0.65625C12.5972 1.09375 13.4792 1.6875 14.2292 2.4375C14.9792 3.1875 15.5729 4.06944 16.0104 5.08333C16.4479 6.09722 16.6667 7.18056 16.6667 8.33333C16.6667 9.48611 16.4479 10.5694 16.0104 11.5833C15.5729 12.5972 14.9792 13.4792 14.2292 14.2292C13.4792 14.9792 12.5972 15.5729 11.5833 16.0104C10.5694 16.4479 9.48611 16.6667 8.33333 16.6667ZM8.33333 15C10.1944 15 11.7708 14.3542 13.0625 13.0625C14.3542 11.7708 15 10.1944 15 8.33333C15 6.47222 14.3542 4.89583 13.0625 3.60417C11.7708 2.3125 10.1944 1.66667 8.33333 1.66667C6.47222 1.66667 4.89583 2.3125 3.60417 3.60417C2.3125 4.89583 1.66667 6.47222 1.66667 8.33333C1.66667 10.1944 2.3125 11.7708 3.60417 13.0625C4.89583 14.3542 6.47222 15 8.33333 15Z" fill="#004AC6"/></svg>';

  static const warningCircle =
      '<svg width="17" height="17" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M8.33333 12.5C8.56944 12.5 8.76736 12.4201 8.92708 12.2604C9.08681 12.1007 9.16667 11.9028 9.16667 11.6667C9.16667 11.4306 9.08681 11.2326 8.92708 11.0729C8.76736 10.9132 8.56944 10.8333 8.33333 10.8333C8.09722 10.8333 7.89931 10.9132 7.73958 11.0729C7.57986 11.2326 7.5 11.4306 7.5 11.6667C7.5 11.9028 7.57986 12.1007 7.73958 12.2604C7.89931 12.4201 8.09722 12.5 8.33333 12.5ZM7.5 9.16667H9.16667V4.16667H7.5V9.16667ZM8.33333 16.6667C7.18056 16.6667 6.09722 16.4479 5.08333 16.0104C4.06944 15.5729 3.1875 14.9792 2.4375 14.2292C1.6875 13.4792 1.09375 12.5972 0.65625 11.5833C0.21875 10.5694 0 9.48611 0 8.33333C0 7.18056 0.21875 6.09722 0.65625 5.08333C1.09375 4.06944 1.6875 3.1875 2.4375 2.4375C3.1875 1.6875 4.06944 1.09375 5.08333 0.65625C6.09722 0.21875 7.18056 0 8.33333 0C9.48611 0 10.5694 0.21875 11.5833 0.65625C12.5972 1.09375 13.4792 1.6875 14.2292 2.4375C14.9792 3.1875 15.5729 4.06944 16.0104 5.08333C16.4479 6.09722 16.6667 7.18056 16.6667 8.33333C16.6667 9.48611 16.4479 10.5694 16.0104 11.5833C15.5729 12.5972 14.9792 13.4792 14.2292 14.2292C13.4792 14.9792 12.5972 15.5729 11.5833 16.0104C10.5694 16.4479 9.48611 16.6667 8.33333 16.6667ZM8.33333 15C10.1944 15 11.7708 14.3542 13.0625 13.0625C14.3542 11.7708 15 10.1944 15 8.33333C15 6.47222 14.3542 4.89583 13.0625 3.60417C11.7708 2.3125 10.1944 1.66667 8.33333 1.66667C6.47222 1.66667 4.89583 2.3125 3.60417 3.60417C2.3125 4.89583 1.66667 6.47222 1.66667 8.33333C1.66667 10.1944 2.3125 11.7708 3.60417 13.0625C4.89583 14.3542 6.47222 15 8.33333 15Z" fill="#BA1A1A"/></svg>';

  static const cart =
      '<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M4.5 15C4.0875 15 3.73438 14.8531 3.44062 14.5594C3.14687 14.2656 3 13.9125 3 13.5C3 13.0875 3.14687 12.7344 3.44062 12.4406C3.73438 12.1469 4.0875 12 4.5 12C4.9125 12 5.26562 12.1469 5.55937 12.4406C5.85312 12.7344 6 13.0875 6 13.5C6 13.9125 5.85312 14.2656 5.55937 14.5594C5.26562 14.8531 4.9125 15 4.5 15ZM12 15C11.5875 15 11.2344 14.8531 10.9406 14.5594C10.6469 14.2656 10.5 13.9125 10.5 13.5C10.5 13.0875 10.6469 12.7344 10.9406 12.4406C11.2344 12.1469 11.5875 12 12 12C12.4125 12 12.7656 12.1469 13.0594 12.4406C13.3531 12.7344 13.5 13.0875 13.5 13.5C13.5 13.9125 13.3531 14.2656 13.0594 14.5594C12.7656 14.8531 12.4125 15 12 15ZM3.8625 3L5.6625 6.75H10.9125L12.975 3H3.8625ZM3.15 1.5H14.2125C14.5 1.5 14.7188 1.62812 14.8687 1.88437C15.0187 2.14062 15.025 2.4 14.8875 2.6625L12.225 7.4625C12.0875 7.7125 11.9031 7.90625 11.6719 8.04375C11.4406 8.18125 11.1875 8.25 10.9125 8.25H5.325L4.5 9.75H13.5V11.25H4.5C3.9375 11.25 3.5125 11.0031 3.225 10.5094C2.9375 10.0156 2.925 9.525 3.1875 9.0375L4.2 7.2L1.5 1.5H0V0H2.4375L3.15 1.5ZM5.6625 6.75H10.9125H5.6625Z" fill="#191C1E"/></svg>';

  static const plus =
      '<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M6 8H0V6H6V0H8V6H14V8H8V14H6V8Z" fill="#434655"/></svg>';

  static const mic =
      '<svg width="17" height="23" viewBox="0 0 17 23" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M8.16667 14C7.19444 14 6.36806 13.6597 5.6875 12.9792C5.00694 12.2986 4.66667 11.4722 4.66667 10.5V3.5C4.66667 2.52778 5.00694 1.70139 5.6875 1.02083C6.36806 0.340278 7.19444 0 8.16667 0C9.13889 0 9.96528 0.340278 10.6458 1.02083C11.3264 1.70139 11.6667 2.52778 11.6667 3.5V10.5C11.6667 11.4722 11.3264 12.2986 10.6458 12.9792C9.96528 13.6597 9.13889 14 8.16667 14ZM7 22.1667V18.5792C4.97778 18.3069 3.30556 17.4028 1.98333 15.8667C0.661111 14.3306 0 12.5417 0 10.5H2.33333C2.33333 12.1139 2.90208 13.4896 4.03958 14.6271C5.17708 15.7646 6.55278 16.3333 8.16667 16.3333C9.78056 16.3333 11.1562 15.7646 12.2937 14.6271C13.4312 13.4896 14 12.1139 14 10.5H16.3333C16.3333 12.5417 15.6722 14.3306 14.35 15.8667C13.0278 17.4028 11.3556 18.3069 9.33333 18.5792V22.1667H7ZM8.16667 11.6667C8.49722 11.6667 8.77431 11.5549 8.99792 11.3313C9.22153 11.1076 9.33333 10.8306 9.33333 10.5V3.5C9.33333 3.16944 9.22153 2.89236 8.99792 2.66875C8.77431 2.44514 8.49722 2.33333 8.16667 2.33333C7.83611 2.33333 7.55903 2.44514 7.33542 2.66875C7.11181 2.89236 7 3.16944 7 3.5V10.5Z" fill="white"/></svg>';
}

class AiClarificationScreen extends StatelessWidget {
  final AiOrderResponse? initialResponse;
  const AiClarificationScreen({super.key, this.initialResponse});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiClarificationController());
    if (initialResponse != null) {
      controller.setInitialData(initialResponse!);
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: SafeArea(
          child: Column(
            children: [
              AnimatedEntrance(
                beginOffset: const Offset(0, -0.2),
                child: _buildHeader(),
              ),
              Expanded(child: _buildChatArea(controller)),
              _buildInputArea(controller),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: -1),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF8FF),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: const Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1.h)),
          ],
        ),
        child: SizedBox(
          height: 64.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedPressable(
                      borderRadius: BorderRadius.circular(999.r),
                      onTap: () => Get.snackbar('الإشعارات', 'لا توجد إشعارات جديدة حالياً'),
                      child: SizedBox(
                        width: 48.w,
                        height: 48.h,
                        child: Center(
                          child: SvgPicture.string(_Icons.bell, width: 16.w, height: 20.h),
                        ),
                      ),
                    ),
                    AnimatedPressable(
                      borderRadius: BorderRadius.circular(999.r),
                      onTap: () => Get.snackbar('القائمة', 'عناصر القائمة قريباً'),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: SvgPicture.string(_Icons.menu, width: 26.w, height: 20.h),
                      ),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Image.asset(
                    'assets/images/salasel_logo.png',
                    width: 70.w,
                    height: 47.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(AiClarificationController controller) {
    return Obx(
      () => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < controller.messages.length; i++) ...[
              AnimatedEntrance(
                delay: Duration(milliseconds: 60 + i * 90),
                beginOffset: const Offset(0, 0.08),
                child: _buildEntry(controller.messages[i]),
              ),
              SizedBox(height: 24.h),
            ],
            AnimatedEntrance(
              delay: Duration(milliseconds: 60 + controller.messages.length * 90),
              child: _QuickRepliesRow(controller: controller),
            ),
            SizedBox(height: 24.h),
            AnimatedEntrance(
              delay: Duration(milliseconds: 150 + controller.messages.length * 90),
              beginOffset: const Offset(0, 0.12),
              child: _OrderPreviewCard(controller: controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntry(ChatEntry entry) {
    return switch (entry) {
      VoiceMessageEntry() => _VoiceMessageBubble(entry: entry),
      AiAnalysisEntry() => _AiAnalysisCard(entry: entry),
      ClarificationEntry() => _ClarificationBubble(entry: entry),
      ConfirmationEntry() => _ConfirmationBubble(entry: entry),
    };
  }

  Widget _buildInputArea(AiClarificationController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xE6F7F9FB),
        border: Border(top: BorderSide(color: const Color(0xFFE6E8EA))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedPressable(
            borderRadius: BorderRadius.circular(999.r),
            onTap: () => Get.snackbar('تسجيل صوتي', 'جارٍ الاستماع لردك...'),
            child: Container(
              width: 56.w,
              height: 56.h,
              decoration: const BoxDecoration(
                color: Color(0xFF004AC6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
                  BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 4)),
                ],
              ),
              child: Center(
                child: SvgPicture.string(_Icons.mic, width: 17.w, height: 23.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              height: 48.h,
              padding: EdgeInsets.fromLTRB(20.w, 11.h, 40.w, 11.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: TextField(
                controller: controller.textController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                onSubmitted: (_) => controller.sendMessage(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF191C1E),
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'اكتب ردك هنا...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          AnimatedPressable(
            borderRadius: BorderRadius.circular(999.r),
            onTap: controller.sendMessage,
            child: SizedBox(
              width: 40.w,
              height: 40.h,
              child: Center(
                child: SvgPicture.string(_Icons.plus, width: 14.w, height: 14.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceMessageBubble extends StatelessWidget {
  final VoiceMessageEntry entry;

  const _VoiceMessageBubble({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 304.3.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFF004AC6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.zero,
              bottomRight: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'رسالة صوتية (${entry.duration})',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: (16 / 12).h,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SvgPicture.string(_Icons.waveform, width: 11.w, height: 15.h),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                entry.transcript,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: (26 / 16).h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiAnalysisCard extends StatelessWidget {
  final AiAnalysisEntry entry;

  const _AiAnalysisCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 322.2.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE6E8EA)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.circular(12.r),
              bottomRight: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.title,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004AC6),
                  height: (26 / 16).h,
                ),
              ),
              SizedBox(height: 12.h),
              for (int i = 0; i < entry.items.length; i++) ...[
                _OrderLineChip(item: entry.items[i]),
                if (i != entry.items.length - 1) SizedBox(height: 8.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderLineChip extends StatelessWidget {
  final OrderLineItem item;

  const _OrderLineChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color textColor = item.isMissing ? const Color(0xFFBA1A1A) : const Color(0xFF191C1E);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: item.isMissing ? const Color(0x4DFFDAD6) : const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(8.r),
        border: item.isMissing ? Border.all(color: const Color(0xFFFFDAD6)) : null,
      ),
      child: Row(
        children: [
          Text(
            item.quantity,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: item.isMissing ? 12.sp : 14.sp,
              fontWeight: item.isMissing ? FontWeight.w400 : FontWeight.w600,
              color: textColor,
              height: item.isMissing ? (16 / 12).h : (20 / 14).h,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: item.isMissing ? FontWeight.w500 : FontWeight.w400,
                  color: textColor,
                  height: (20 / 14).h,
                ),
              ),
              SizedBox(width: 8.w),
              SvgPicture.string(
                item.isMissing ? _Icons.warningCircle : _Icons.checkCircle,
                width: 17.w,
                height: 17.h,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClarificationBubble extends StatelessWidget {
  final ClarificationEntry entry;

  const _ClarificationBubble({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 304.3.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF004AC6),
            border: Border.all(color: const Color(0x33004AC6)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.zero,
              bottomRight: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
          ),
          child: Text(
            entry.question,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEEEFFF),
              height: (26 / 16).h,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationBubble extends StatelessWidget {
  final ConfirmationEntry entry;

  const _ConfirmationBubble({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 322.2.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE6E8EA)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.circular(12.r),
              bottomRight: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
          ),
          child: Text(
            entry.message,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF191C1E),
              height: (20 / 14).h,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickRepliesRow extends StatelessWidget {
  final AiClarificationController controller;

  const _QuickRepliesRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.quickReplies.isEmpty) return const SizedBox.shrink();

      return Wrap(
        alignment: WrapAlignment.end,
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          for (final option in controller.quickReplies)
            _QuickReplyChip(
              label: option,
              onTap: () => controller.selectSugarQuantity(option),
            ),
          _SkipChip(onTap: controller.skipSugarQuantity),
        ],
      );
    });
  }
}

class _QuickReplyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickReplyChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFC3C6D7)),
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: [
            BoxShadow(color: const Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1.h)),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF191C1E),
            height: (20 / 14).h,
          ),
        ),
      ),
    );
  }
}

class _SkipChip extends StatelessWidget {
  final VoidCallback onTap;

  const _SkipChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: Container(
        width: 122.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFBA1A1A),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          'تخطي',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: (20 / 14).h,
          ),
        ),
      ),
    );
  }
}

class _OrderPreviewCard extends StatelessWidget {
  final AiClarificationController controller;

  const _OrderPreviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ملخص الطلب المبدئي',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF191C1E),
                  height: (20 / 14).h,
                ),
              ),
              SizedBox(width: 8.w),
              SvgPicture.string(_Icons.cart, width: 15.w, height: 15.h),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Opacity(
              opacity: 0.7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < controller.summary.length; i++) ...[
                    _SummaryPair(line: controller.summary[i]),
                    if (i != controller.summary.length - 1) SizedBox(width: 16.w),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPair extends StatelessWidget {
  final OrderSummaryLine line;

  const _SummaryPair({required this.line});

  @override
  Widget build(BuildContext context) {
    final Color color = line.missing ? const Color(0xFFBA1A1A) : const Color(0xFF191C1E);

    final text = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: line.label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
              height: (16 / 12).h,
            ),
          ),
          TextSpan(
            text: ' ${line.value}',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: color,
              height: (16 / 12).h,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.rtl,
    );

    if (!line.missing) return text;

    return Container(
      padding: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFFBA1A1A), width: 1.w)),
      ),
      child: text,
    );
  }
}
