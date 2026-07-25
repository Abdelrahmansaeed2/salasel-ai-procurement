import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../voice_order/presentation/screens/voice_recording_screen.dart';
import '../controllers/home_controller.dart';
import '../theme/home_colors.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/recent_order_tile.dart';

const String _avatarUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/c7070914a8d0a025b8aab03d2f42684260d4b530?width=72';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              AnimatedEntrance(
                beginOffset: Offset.zero,
                duration: const Duration(milliseconds: 350),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 60),
                        child: _MicSection(),
                      ),
                      const SizedBox(height: 34),
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 160),
                        child: _buildQuickStats(controller),
                      ),
                      const SizedBox(height: 10),
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 260),
                        child: _buildRecentOrders(controller),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => AppBottomNavBar(
            currentIndex: controller.bottomNavIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: HomeColors.headerBg,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
        children: [
          AnimatedPressable(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.snackbar('الإشعارات', 'لا توجد إشعارات جديدة حالياً'),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.string(
                  '<svg width="16" height="20" viewBox="0 0 16 20" fill="none" xmlns="http://www.w3.org/2000/svg">'
                  '<path d="M0 17V15H2V8C2 6.61667 2.41667 5.3875 3.25 4.3125C4.08333 3.2375 5.16667 2.53333 6.5 2.2V1.5C6.5 1.08333 6.64583 0.729167 6.9375 0.4375C7.22917 0.145833 7.58333 0 8 0C8.41667 0 8.77083 0.145833 9.0625 0.4375C9.35417 0.729167 9.5 1.08333 9.5 1.5V2.2C10.8333 2.53333 11.9167 3.2375 12.75 4.3125C13.5833 5.3875 14 6.61667 14 8V15H16V17H0ZM8 20C7.45 20 6.97917 19.8042 6.5875 19.4125C6.19583 19.0208 6 18.55 6 18H10C10 18.55 9.80417 19.0208 9.4125 19.4125C9.02083 19.8042 8.55 20 8 20ZM4 15H12V8C12 6.9 11.6083 5.95833 10.825 5.175C10.0417 4.39167 9.1 4 8 4C6.9 4 5.95833 4.39167 5.175 5.175C4.39167 5.95833 4 6.9 4 8V15Z" fill="#434655"/></svg>',
                ),
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'متجر سارة',
            style: TextStyle(
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.73,
            ),
          ),
          const SizedBox(width: 12),
          AnimatedPressable(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.snackbar('حسابي', 'إدارة حساب المتجر قريباً'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: HomeColors.avatarBorder, width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  _avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: HomeColors.avatarBorder,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildQuickStats(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'لمحة سريعة',
                style: TextStyle(
                  color: HomeColors.sectionTitle,
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: HomeColors.viewAll,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: controller.quickStats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              const variants = [
                QuickStatVariant.lowStock,
                QuickStatVariant.delivery,
                QuickStatVariant.pending,
              ];
              final stat = controller.quickStats[index];
              final variant = variants[index];
              return AnimatedEntrance(
                delay: Duration(milliseconds: 80 * index),
                beginOffset: const Offset(0.12, 0),
                child: QuickStatCard(
                  variant: variant,
                  label: stat.label,
                  value: stat.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Text(
                'آخر الطلبات',
                style: TextStyle(
                  color: HomeColors.sectionTitle,
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: HomeColors.viewAll,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...List.generate(controller.recentOrders.length, (index) {
            final order = controller.recentOrders[index];
            return AnimatedEntrance(
              delay: Duration(milliseconds: 100 * index),
              child: RecentOrderTile(
                order: order,
                showDivider: index != controller.recentOrders.length - 1,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MicSection extends StatefulWidget {
  const _MicSection();

  @override
  State<_MicSection> createState() => _MicSectionState();
}

class _MicSectionState extends State<_MicSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openVoiceRecording() {
    Get.to(
      () => const VoiceRecordingScreen(),
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 209,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final t = _pulseController.value;
                    return Transform.scale(
                      scale: 1 + (t * 0.06),
                      child: Opacity(
                        opacity: 1 - (t * 0.4),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 216,
                    height: 216,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x052563EB)),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final t = _pulseController.value;
                    return Transform.scale(
                      scale: 1 + (t * 0.045),
                      child: Opacity(
                        opacity: 1 - (t * 0.3),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 188,
                    height: 188,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x0D2563EB)),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final t = _pulseController.value;
                    return Transform.scale(
                      scale: 1 + (t * 0.03),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x1A2563EB)),
                      color: const Color(0x1A2563EB),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final t = _pulseController.value;
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x1A2563EB),
                            blurRadius: 35 + (t * 15),
                            spreadRadius: 15 + (t * 6),
                          ),
                        ],
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
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _openVoiceRecording,
                        child: Container(
                          width: 136,
                          height: 136,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                HomeColors.micGradientStart,
                                HomeColors.micGradientEnd,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: HomeColors.micGradientStart.withValues(alpha: 0.4),
                                blurRadius: 36,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/mic_icon.svg',
                                width: 34,
                                height: 37,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'اضغط للطلب',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.25,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'اضغط واطلب بضاعتك',
              style: TextStyle(
                color: HomeColors.ctaText,
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(
            width: 250,
            child: Text(
              'الذكاء الاصطناعي جاهز لتلقي طلبك الصوتي',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HomeColors.subtitle,
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
