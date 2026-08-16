import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../voice_order/presentation/controllers/voice_recording_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/network/api_client.dart';
import 'package:dio/dio.dart' as dio;

class VoiceInventoryScreen extends StatelessWidget {
  const VoiceInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoiceRecordingController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                AnimatedEntrance(
                  beginOffset: Offset(0, -0.2),
                  child: _buildTopBar(),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedEntrance(
                          delay: Duration(milliseconds: 80),
                          child: SizedBox(
                            height: 244.h,
                            child: Obx(
                              () => _Waveform(bars: controller.waveform.toList()),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        AnimatedEntrance(
                          delay: Duration(milliseconds: 160),
                          child: _MicCore(controller: controller),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 56.h),
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: controller.isRecording.value
                          ? _RecordingActions(
                              key: ValueKey('recording'),
                              controller: controller,
                            )
                          : _StartButton(
                              key: ValueKey('idle'),
                              controller: controller,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedPressable(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => Get.back(),
          child: Container(
            width: 36.w,
            height: 36.h,
            alignment: Alignment.center,
            child: SvgPicture.string(
              '<svg width="34" height="34" viewBox="0 0 34 34" fill="none" xmlns="http://www.w3.org/2000/svg">'
              '<path d="M25.5 8.5L8.5 25.5" stroke="white" stroke-opacity="0.6" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
              '<path d="M8.5 8.5L25.5 25.5" stroke="white" stroke-opacity="0.6" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
              '</svg>',
            ),
          ),
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final List<double> bars;
  const _Waveform({required this.bars});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 202.w,
          height: 202.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0xFF6366F1).withValues(alpha: 0.06),
                Color(0xFF6366F1).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        Container(
          width: 160.w,
          height: 160.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0xFF6366F1).withValues(alpha: 0.11),
                Color(0xFF6366F1).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 256.w,
          height: 160.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final h in bars)
                AnimatedContainer(
                  duration: Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  width: 4.w,
                  height: 12.h + h * 130,
                  decoration: BoxDecoration(
                    color: Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MicCore extends StatefulWidget {
  final VoiceRecordingController controller;
  const _MicCore({required this.controller});

  @override
  State<_MicCore> createState() => _MicCoreState();
}

class _MicCoreState extends State<_MicCore> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400),
    );
    widget.controller.isRecording.listen((recording) {
      if (recording) {
        _pulse.repeat();
      } else {
        _pulse.stop();
        _pulse.reset();
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          SizedBox(
            width: 140.w,
            height: 140.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.controller.isRecording.value)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final t = _pulse.value;
                      return Container(
                        width: 72.w + t * 60,
                        height: 72.h + t * 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF235EE7).withValues(alpha: (1 - t) * 0.5),
                            width: 1.5.w,
                          ),
                        ),
                      );
                    },
                  ),
                if (widget.controller.isRecording.value)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final t = (_pulse.value + 0.5) % 1.0;
                      return Container(
                        width: 72.w + t * 60,
                        height: 72.h + t * 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF235EE7).withValues(alpha: (1 - t) * 0.5),
                            width: 1.5.w,
                          ),
                        ),
                      );
                    },
                  ),
                GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  child: AnimatedScale(
                    scale: _pressed ? 0.94 : 1,
                    duration: Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: Container(
                      width: 72.w,
                      height: 72.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0x4D818CF8)),
                        color: Color(0xFF235EE7),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/mic_icon.svg',
                          width: 28.w,
                          height: 32.h,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withValues(alpha: 0.5),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: Text(
              widget.controller.isRecording.value ? 'جاري الاستماع...' : 'اضغط للبدء',
              key: ValueKey(widget.controller.isRecording.value),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.5.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoiceRecordingController controller;
  const _StartButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(8.r),
      onTap: controller.startRecording,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: Color(0xFF235EE7),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(
              '<svg width="23" height="23" viewBox="0 0 23 23" fill="none" xmlns="http://www.w3.org/2000/svg">'
              '<path d="M14.375 4.7915C14.375 3.20369 13.0878 1.9165 11.5 1.9165C9.91218 1.9165 8.625 3.20369 8.625 4.7915V9.58317C8.625 11.171 9.91218 12.4582 11.5 12.4582C13.0878 12.4582 14.375 11.171 14.375 9.58317V4.7915Z" fill="white"/>'
              '<path d="M4.79163 10.5415C4.79163 12.3207 5.49839 14.027 6.75645 15.285C8.01451 16.5431 9.7208 17.2498 11.5 17.2498C13.2791 17.2498 14.9854 16.5431 16.2435 15.285C17.5015 14.027 18.2083 12.3207 18.2083 10.5415" stroke="white" stroke-width="1.5" stroke-linecap="round"/>'
              '<path d="M11.5 17.25V21.0833" stroke="white" stroke-width="1.5" stroke-linecap="round"/>'
              '<path d="M8.625 21.0835H14.375" stroke="white" stroke-width="1.5" stroke-linecap="round"/></svg>',
            ),
            SizedBox(width: 10.w),
            Text(
              'ابدأ التسجيل الصوتي',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                height: 1.5.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingActions extends StatelessWidget {
  final VoiceRecordingController controller;
  const _RecordingActions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          label: 'تأكيد',
          color: Color(0xFF22C55E),
          textColor: Color(0xFF22C55E),
          iconPath:
              'M8.08073 13.7538L14.8038 7.03073L13.75 5.97691L8.08073 11.6461L5.23073 8.79614L4.17691 9.84996L8.08073 13.7538Z',
          onTap: () async {
            final path = await controller.stopRecording();
            if (path != null) {
              // Upload and parse
              Get.dialog(const Center(child: CircularProgressIndicator()));
              try {
                final apiClient = ApiClient();
                final formData = dio.FormData.fromMap({
                  'audio': await dio.MultipartFile.fromFile(path, filename: 'inventory_audio.m4a'),
                });
                final response = await apiClient.dio.post('/ai/inventory-voice', data: formData);
                Get.back(); // close loading
                if (response.statusCode == 200) {
                  Get.back(result: response.data); // return to add inventory screen
                } else {
                  Get.snackbar('خطأ', 'فشل في تحليل الصوت.');
                }
              } catch (e) {
                Get.back(); // close loading
                Get.snackbar('خطأ', 'فشل في تحليل الصوت.');
              }
            }
          },
        ),
        _StopButton(controller: controller),
        _ActionButton(
          label: 'إلغاء الأمر',
          color: Color(0xFFBA1A1A),
          textColor: Color(0xFFBA1A1A),
          iconPath:
              'M5.89996 14.1538L9.49996 10.5538L13.1 14.1538L14.1538 13.1L10.5538 9.49996L14.1538 5.89996L13.1 4.84614L9.49996 8.44614L5.89996 4.84614L4.84614 5.89996L8.44614 9.49996L4.84614 13.1L5.89996 14.1538Z',
          onTap: controller.stopRecording,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final String iconPath;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedPressable(
          borderRadius: BorderRadius.circular(999.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Color(0x33737686)),
            ),
            child: SvgPicture.string(
              '<svg width="19" height="19" viewBox="0 0 19 19" fill="none" xmlns="http://www.w3.org/2000/svg">'
              '<path d="M9.50164 18.9999C8.18771 18.9999 6.95267 18.7506 5.79653 18.2519C4.64039 17.7533 3.63471 17.0765 2.77948 16.2217C1.92426 15.3668 1.2472 14.3616 0.748323 13.206C0.249441 12.0503 0 10.8156 0 9.50164C0 8.18771 0.24933 6.95267 0.74799 5.79653C1.24665 4.64039 1.9234 3.63471 2.77825 2.77948C3.6331 1.92426 4.63833 1.24721 5.79396 0.748323C6.94958 0.249441 8.18436 0 9.49829 0C10.8122 0 12.0473 0.24933 13.2034 0.74799C14.3595 1.24665 15.3652 1.9234 16.2204 2.77825C17.0757 3.6331 17.7527 4.63833 18.2516 5.79396C18.7505 6.94958 18.9999 8.18436 18.9999 9.49829C18.9999 10.8122 18.7506 12.0473 18.2519 13.2034C17.7533 14.3595 17.0765 15.3652 16.2217 16.2204C15.3668 17.0757 14.3616 17.7527 13.206 18.2516C12.0503 18.7505 10.8156 18.9999 9.50164 18.9999ZM9.49996 17.5C11.7333 17.5 13.625 16.725 15.175 15.175C16.725 13.625 17.5 11.7333 17.5 9.49996C17.5 7.26663 16.725 5.37496 15.175 3.82496C13.625 2.27496 11.7333 1.49996 9.49996 1.49996C7.26663 1.49996 5.37496 2.27496 3.82496 3.82496C2.27496 5.37496 1.49996 7.26663 1.49996 9.49996C1.49996 11.7333 2.27496 13.625 3.82496 15.175C5.37496 16.725 7.26663 17.5 9.49996 17.5Z" fill="white"/>'
              '<path d="$iconPath" fill="white"/></svg>',
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            height: 1.h,
          ),
        ),
      ],
    );
  }
}

class _StopButton extends StatelessWidget {
  final VoiceRecordingController controller;
  const _StopButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedPressable(
          borderRadius: BorderRadius.circular(999.r),
          onTap: controller.stopRecording,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFDAD6),
            ),
            child: SvgPicture.string(
              '<svg width="23" height="23" viewBox="0 0 23 23" fill="none" xmlns="http://www.w3.org/2000/svg">'
              '<path d="M6.75 15.75H15.75V6.75H6.75V15.75ZM11.25 22.5C9.69375 22.5 8.23125 22.2047 6.8625 21.6141C5.49375 21.0234 4.30312 20.2219 3.29062 19.2094C2.27812 18.1969 1.47656 17.0063 0.885937 15.6375C0.295312 14.2687 0 12.8062 0 11.25C0 9.69375 0.295312 8.23125 0.885937 6.8625C1.47656 5.49375 2.27812 4.30312 3.29062 3.29062C4.30312 2.27812 5.49375 1.47656 6.8625 0.885937C8.23125 0.295312 9.69375 0 11.25 0C12.8062 0 14.2687 0.295312 15.6375 0.885937C17.0063 1.47656 18.1969 2.27812 19.2094 3.29062C20.2219 4.30312 21.0234 5.49375 21.6141 6.8625C22.2047 8.23125 22.5 9.69375 22.5 11.25C22.5 12.8062 22.2047 14.2687 21.6141 15.6375C21.0234 17.0063 20.2219 18.1969 19.2094 19.2094C18.1969 20.2219 17.0063 21.0234 15.6375 21.6141C14.2687 22.2047 12.8062 22.5 11.25 22.5Z" fill="#93000A"/></svg>',
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'إيقاف',
          style: TextStyle(
            color: Color(0xFF434655),
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            height: 1.h,
          ),
        ),
      ],
    );
  }
}
