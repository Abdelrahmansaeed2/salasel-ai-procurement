import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../orders/presentation/screens/order_review_screen.dart';
import '../controllers/ai_processing_controller.dart';

const String _mascotImageUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/19eb72610d6164c84c2c7c050a710ebf5cd2ee1b?width=282';

class _StepIcon {
  final double width;
  final double height;
  final String path;
  const _StepIcon({required this.width, required this.height, required this.path});
}

const List<_StepIcon> _stepIcons = [
  _StepIcon(
    width: 17,
    height: 17,
    path:
        'M7.16667 12.1667L13.0417 6.29167L11.875 5.125L7.16667 9.83333L4.79167 7.45833L3.625 8.625L7.16667 12.1667ZM8.33333 16.6667C7.18056 16.6667 6.09722 16.4479 5.08333 16.0104C4.06944 15.5729 3.1875 14.9792 2.4375 14.2292C1.6875 13.4792 1.09375 12.5972 0.65625 11.5833C0.21875 10.5694 0 9.48611 0 8.33333C0 7.18056 0.21875 6.09722 0.65625 5.08333C1.09375 4.06944 1.6875 3.1875 2.4375 2.4375C3.1875 1.6875 4.06944 1.09375 5.08333 0.65625C6.09722 0.21875 7.18056 0 8.33333 0C9.48611 0 10.5694 0.21875 11.5833 0.65625C12.5972 1.09375 13.4792 1.6875 14.2292 2.4375C14.9792 3.1875 15.5729 4.06944 16.0104 5.08333C16.4479 6.09722 16.6667 7.18056 16.6667 8.33333C16.6667 9.48611 16.4479 10.5694 16.0104 11.5833C15.5729 12.5972 14.9792 13.4792 14.2292 14.2292C13.4792 14.9792 12.5972 15.5729 11.5833 16.0104C10.5694 16.4479 9.48611 16.6667 8.33333 16.6667Z',
  ),
  _StepIcon(
    width: 16,
    height: 17,
    path:
        'M6.66667 10.8333H8.33333L8.45833 9.79167C8.56944 9.75 8.67014 9.70139 8.76042 9.64583C8.85069 9.59028 8.93056 9.52778 9 9.45833L9.95833 9.875L10.7917 8.45833L9.95833 7.83333C9.98611 7.72222 10 7.61111 10 7.5C10 7.38889 9.98611 7.27778 9.95833 7.16667L10.7917 6.54167L9.95833 5.125L9 5.54167C8.93056 5.47222 8.85069 5.40972 8.76042 5.35417C8.67014 5.29861 8.56944 5.25 8.45833 5.20833L8.33333 4.16667H6.66667L6.54167 5.20833C6.43056 5.25 6.32986 5.29861 6.23958 5.35417C6.14931 5.40972 6.06944 5.47222 6 5.54167L5.04167 5.125L4.20833 6.54167L5.04167 7.16667C5.01389 7.27778 5 7.38889 5 7.5C5 7.61111 5.01389 7.72222 5.04167 7.83333L4.20833 8.45833L5.04167 9.875L6 9.45833C6.06944 9.52778 6.14931 9.59028 6.23958 9.64583C6.32986 9.70139 6.43056 9.75 6.54167 9.79167L6.66667 10.8333ZM7.5 8.75C7.15278 8.75 6.85764 8.62847 6.61458 8.38542C6.37153 8.14236 6.25 7.84722 6.25 7.5C6.25 7.15278 6.37153 6.85764 6.61458 6.61458C6.85764 6.37153 7.15278 6.25 7.5 6.25C7.84722 6.25 8.14236 6.37153 8.38542 6.61458C8.62847 6.85764 8.75 7.15278 8.75 7.5C8.75 7.84722 8.62847 8.14236 8.38542 8.38542C8.14236 8.62847 7.84722 8.75 7.5 8.75ZM2.5 16.6667V13.0833C1.70833 12.3611 1.09375 11.5174 0.65625 10.5521C0.21875 9.58681 0 8.56944 0 7.5C0 5.41667 0.729167 3.64583 2.1875 2.1875C3.64583 0.729167 5.41667 0 7.5 0C9.23611 0 10.7743 0.510417 12.1146 1.53125C13.4549 2.55208 14.3264 3.88194 14.7292 5.52083L15.8125 9.79167C15.8819 10.0556 15.8333 10.2951 15.6667 10.5104C15.5 10.7257 15.2778 10.8333 15 10.8333H13.3333V13.3333C13.3333 13.7917 13.1701 14.184 12.8438 14.5104C12.5174 14.8368 12.125 15 11.6667 15H10V16.6667H2.5Z',
  ),
  _StepIcon(
    width: 17,
    height: 17,
    path:
        'M2.5 16.6667C2.04167 16.6667 1.64931 16.5035 1.32292 16.1771C0.996528 15.8507 0.833333 15.4583 0.833333 15V5.60417C0.583333 5.45139 0.381944 5.25347 0.229167 5.01042C0.0763889 4.76736 0 4.48611 0 4.16667V1.66667C0 1.20833 0.163194 0.815972 0.489583 0.489583C0.815972 0.163194 1.20833 0 1.66667 0H15C15.4583 0 15.8507 0.163194 16.1771 0.489583C16.5035 0.815972 16.6667 1.20833 16.6667 1.66667V4.16667C16.6667 4.48611 16.5903 4.76736 16.4375 5.01042C16.2847 5.25347 16.0833 5.45139 15.8333 5.60417V15C15.8333 15.4583 15.6701 15.8507 15.3438 16.1771C15.0174 16.5035 14.625 16.6667 14.1667 16.6667H2.5ZM2.5 5.83333V15H14.1667V5.83333H2.5ZM1.66667 4.16667H15V1.66667H1.66667V4.16667ZM5.83333 10H10.8333V8.33333H5.83333V10Z',
  ),
  _StepIcon(
    width: 19,
    height: 14,
    path:
        'M4.16667 13.3333C3.47222 13.3333 2.88194 13.0903 2.39583 12.6042C1.90972 12.1181 1.66667 11.5278 1.66667 10.8333H0V1.66667C0 1.20833 0.163194 0.815972 0.489583 0.489583C0.815972 0.163194 1.20833 0 1.66667 0H13.3333V3.33333H15.8333L18.3333 6.66667V10.8333H16.6667C16.6667 11.5278 16.4236 12.1181 15.9375 12.6042C15.4514 13.0903 14.8611 13.3333 14.1667 13.3333C13.4722 13.3333 12.8819 13.0903 12.3958 12.6042C11.9097 12.1181 11.6667 11.5278 11.6667 10.8333H6.66667C6.66667 11.5278 6.42361 12.1181 5.9375 12.6042C5.45139 13.0903 4.86111 13.3333 4.16667 13.3333ZM4.16667 11.6667C4.40278 11.6667 4.60069 11.5868 4.76042 11.4271C4.92014 11.2674 5 11.0694 5 10.8333C5 10.5972 4.92014 10.3993 4.76042 10.2396C4.60069 10.0799 4.40278 10 4.16667 10C3.93056 10 3.73264 10.0799 3.57292 10.2396C3.41319 10.3993 3.33333 10.5972 3.33333 10.8333C3.33333 11.0694 3.41319 11.2674 3.57292 11.4271C3.73264 11.5868 3.93056 11.6667 4.16667 11.6667ZM1.66667 9.16667H2.33333C2.56944 8.91667 2.84028 8.71528 3.14583 8.5625C3.45139 8.40972 3.79167 8.33333 4.16667 8.33333C4.54167 8.33333 4.88194 8.40972 5.1875 8.5625C5.49306 8.71528 5.76389 8.91667 6 9.16667H11.6667V1.66667H1.66667V9.16667ZM14.1667 11.6667C14.4028 11.6667 14.6007 11.5868 14.7604 11.4271C14.9201 11.2674 15 11.0694 15 10.8333C15 10.5972 14.9201 10.3993 14.7604 10.2396C14.6007 10.0799 14.4028 10 14.1667 10C13.9306 10 13.7326 10.0799 13.5729 10.2396C13.4132 10.3993 13.3333 10.5972 13.3333 10.8333C13.3333 11.0694 13.4132 11.2674 13.5729 11.4271C13.7326 11.5868 13.9306 11.6667 14.1667 11.6667ZM13.3333 7.5H16.875L15 5H13.3333V7.5Z',
  ),
];

class _AnimatedMascotImage extends StatelessWidget {
  const _AnimatedMascotImage();

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _mascotImageUrl,
      width: 141,
      height: 166.56,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 400),
      fadeInCurve: Curves.easeOut,
      progressIndicatorBuilder: (context, url, progress) =>
          _MascotLoadingPlaceholder(progress: progress.progress),
      errorWidget: (_, __, ___) => const SizedBox(width: 141, height: 166.56),
    );
  }
}

class _MascotLoadingPlaceholder extends StatefulWidget {
  final double? progress;
  const _MascotLoadingPlaceholder({this.progress});

  @override
  State<_MascotLoadingPlaceholder> createState() => _MascotLoadingPlaceholderState();
}

class _MascotLoadingPlaceholderState extends State<_MascotLoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 141,
      height: 166.56,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final opacity = 0.35 + (_pulse.value * 0.25);
          return Opacity(opacity: opacity, child: child);
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE5E7EB),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    value: widget.progress,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 90,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AiProcessingScreen extends StatelessWidget {
  const AiProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiProcessingController());
    controller.start(() {
      Get.off(
        () => const OrderReviewScreen(),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 350),
      );
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                AnimatedEntrance(
                  beginOffset: const Offset(0, -0.2),
                  child: _buildHeader(),
                ),
                const SizedBox(height: 32),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 100),
                  beginOffset: const Offset(0, 0.15),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                    child: const _AnimatedMascotImage(),
                  ),
                ),
                const SizedBox(height: 40),
                const AnimatedEntrance(
                  delay: Duration(milliseconds: 180),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'جاري المعالجة الذكية',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        letterSpacing: 1.6,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _StepsList(controller: controller),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, value, child) => Opacity(opacity: value, child: child),
                    child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'الوقت المتوقع للتجهيز: ٣ ثوانٍ',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: SvgPicture.string(
                            '<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">'
                            '<path d="M7.75833 8.575L8.575 7.75833L6.41667 5.6V2.91667H5.25V6.06667L7.75833 8.575ZM5.83333 11.6667C5.02639 11.6667 4.26806 11.5135 3.55833 11.2073C2.84861 10.901 2.23125 10.4854 1.70625 9.96042C1.18125 9.43542 0.765625 8.81806 0.459375 8.10833C0.153125 7.39861 0 6.64028 0 5.83333C0 5.02639 0.153125 4.26806 0.459375 3.55833C0.765625 2.84861 1.18125 2.23125 1.70625 1.70625C2.23125 1.18125 2.84861 0.765625 3.55833 0.459375C4.26806 0.153125 5.02639 0 5.83333 0C6.64028 0 7.39861 0.153125 8.10833 0.459375C8.81806 0.765625 9.43542 1.18125 9.96042 1.70625C10.4854 2.23125 10.901 2.84861 11.2073 3.55833C11.5135 4.26806 11.6667 5.02639 11.6667 5.83333C11.6667 6.64028 11.5135 7.39861 11.2073 8.10833C10.901 8.81806 10.4854 9.43542 9.96042 9.96042C9.43542 10.4854 8.81806 10.901 8.10833 11.2073C7.39861 11.5135 6.64028 11.6667 5.83333 11.6667ZM5.83333 10.5C7.12639 10.5 8.22743 10.0455 9.13646 9.13646C10.0455 8.22743 10.5 7.12639 10.5 5.83333C10.5 4.54028 10.0455 3.43924 9.13646 2.53021C8.22743 1.62118 7.12639 1.16667 5.83333 1.16667C4.54028 1.16667 3.43924 1.62118 2.53021 2.53021C1.62118 3.43924 1.16667 4.54028 1.16667 5.83333C1.16667 7.12639 1.62118 8.22743 2.53021 9.13646C3.43924 10.0455 4.54028 10.5 5.83333 10.5Z" fill="#333333"/></svg>',
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: -1),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 64,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            AnimatedPressable(
              borderRadius: BorderRadius.circular(999),
              onTap: () => Get.back(),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 14),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: _HeaderIcon(
                    width: 16,
                    height: 16,
                    path:
                        'M3.825 9L9.425 14.6L8 16L0 8L8 0L9.425 1.4L3.825 7H16V9H3.825Z',
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Text(
                'محرك مشتريات يعمل بالذكاء الاصطناعي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  letterSpacing: -0.4,
                  height: 1.5,
                ),
              ),
            ),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(999),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 14),
                child: SizedBox(
                  width: 4,
                  height: 16,
                  child: _HeaderIcon(
                    width: 4,
                    height: 16,
                    path:
                        'M2 16C1.45 16 0.979167 15.8042 0.5875 15.4125C0.195833 15.0208 0 14.55 0 14C0 13.45 0.195833 12.9792 0.5875 12.5875C0.979167 12.1958 1.45 12 2 12C2.55 12 3.02083 12.1958 3.4125 12.5875C3.80417 12.9792 4 13.45 4 14C4 14.55 3.80417 15.0208 3.4125 15.4125C3.02083 15.8042 2.55 16 2 16ZM2 10C1.45 10 0.979167 9.80417 0.5875 9.4125C0.195833 9.02083 0 8.55 0 8C0 7.45 0.195833 6.97917 0.5875 6.5875C0.979167 6.19583 1.45 6 2 6C2.55 6 3.02083 6.19583 3.4125 6.5875C3.80417 6.97917 4 7.45 4 8C4 8.55 3.80417 9.02083 3.4125 9.4125C3.02083 9.80417 2.55 10 2 10ZM2 4C1.45 4 0.979167 3.80417 0.5875 3.4125C0.195833 3.02083 0 2.55 0 2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0C2.55 0 3.02083 0.195833 3.4125 0.5875C3.80417 0.979167 4 1.45 4 2C4 2.55 3.80417 3.02083 3.4125 3.4125C3.02083 3.80417 2.55 4 2 4Z',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final double width;
  final double height;
  final String path;

  const _HeaderIcon({required this.width, required this.height, required this.path});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg width="$width" height="$height" viewBox="0 0 $width $height" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="$path" fill="black"/></svg>',
    );
  }
}

class _StepsList extends StatelessWidget {
  final AiProcessingController controller;
  const _StepsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeIndex = controller.activeStep.value;
      return _buildStack(activeIndex);
    });
  }

  Widget _buildStack(int activeIndex) {
    final progress = activeIndex / (controller.steps.length - 1);

    return Stack(
      children: [
        Positioned(
          right: 19,
          top: 20,
          bottom: 20,
          child: Container(width: 2, color: const Color(0xFF27272A)),
        ),
        Positioned(
          right: 19,
          top: 20,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 2,
            height: 232 * progress,
            color: const Color(0xFF2563EB),
          ),
        ),
        Column(
          children: List.generate(controller.steps.length, (index) {
            final step = controller.steps[index];
            final state = controller.stateOf(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _StepTile(
                title: step.title,
                subtitle: step.subtitle,
                state: state,
                icon: _stepIcons[index],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final ProcessingStepState state;
  final _StepIcon icon;

  const _StepTile({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isCompletedOrActive = state != ProcessingStepState.pending;
    final bgColor = state == ProcessingStepState.pending
        ? const Color(0xFF27272A)
        : const Color(0xFF2563EB);
    final titleColor = isCompletedOrActive ? const Color(0xFF2563EB) : const Color(0xFF333333);
    final subtitleColor = state == ProcessingStepState.active
        ? const Color(0xCC004AC6)
        : state == ProcessingStepState.completed
            ? const Color(0xFF484848)
            : const Color(0x99484848);

    return Row(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: titleColor,
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: isCompletedOrActive ? FontWeight.w700 : FontWeight.w600,
                  height: 1.56,
                ),
                child: Text(title, textAlign: TextAlign.right),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: subtitleColor,
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  height: 1.43,
                ),
                child: Text(subtitle, textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _StepIconBadge(state: state, bgColor: bgColor, icon: icon),
      ],
    );
  }
}

class _StepIconBadge extends StatefulWidget {
  final ProcessingStepState state;
  final Color bgColor;
  final _StepIcon icon;

  const _StepIconBadge({required this.state, required this.bgColor, required this.icon});

  @override
  State<_StepIconBadge> createState() => _StepIconBadgeState();
}

class _StepIconBadgeState extends State<_StepIconBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.state == ProcessingStepState.active) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _StepIconBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == ProcessingStepState.active) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.icon;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final scale = 1 + (_pulse.value * 0.08);
        return Transform.scale(scale: scale, child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.bgColor,
          boxShadow: widget.state == ProcessingStepState.pending
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                    spreadRadius: -3,
                  ),
                ],
          border: widget.state == ProcessingStepState.pending
              ? Border.all(color: Colors.white.withValues(alpha: 0.2))
              : null,
        ),
        child: SizedBox(
          width: icon.width,
          height: icon.height,
          child: SvgPicture.string(
            '<svg width="${icon.width}" height="${icon.height}" viewBox="0 0 ${icon.width} ${icon.height}" fill="none" xmlns="http://www.w3.org/2000/svg">'
            '<path d="${icon.path}" fill="white"/></svg>',
          ),
        ),
      ),
    );
  }
}
