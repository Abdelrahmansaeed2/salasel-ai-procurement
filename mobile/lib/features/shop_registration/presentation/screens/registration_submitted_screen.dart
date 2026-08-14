import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../controllers/registration_submitted_controller.dart';

const String _kLogoUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/c0e3b351321fdab13103f562fe29b6cd429c3f43?width=140';
const String _kIllustrationUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/5531f3623415028182f0f7fa1c53e3622d8b9530?width=726';

class _C {
  static const textDark = Color(0xFF191C1E);
  static const textBody = Color(0xFF434655);
  static const pendingBg = Color(0x1ABC4800);
  static const pendingText = Color(0xFF943700);
  static const primaryBlue = Color(0xFF004AC6);
  static const ctaBlue = Color(0xFF2563EB);
  static const surfaceGray = Color(0xFFF7F9FB);
  static const borderGray = Color(0x33C3C6D7);
  static const lockedBg = Color(0xFFF2F4F6);
  static const dimGray = Color(0xFFC3C6D7);
  static const mutedIcon = Color(0x66434655);
}

class _Svg {
  static const shieldCheck =
      '<svg width="23" height="27" viewBox="0 0 23 27" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M9.99062 18.2925L18.1125 10.665L16.0641 8.74125L9.99062 14.445L6.97187 11.61L4.92344 13.5337L9.99062 18.2925ZM11.5 27C8.16979 26.2125 5.42057 24.4181 3.25234 21.6169C1.08411 18.8156 0 15.705 0 12.285V4.05L11.5 0L23 4.05V12.285C23 15.705 21.9159 18.8156 19.7477 21.6169C17.5794 24.4181 14.8302 26.2125 11.5 27ZM11.5 24.165C13.9917 23.4225 16.0521 21.9375 17.6812 19.71C19.3104 17.4825 20.125 15.0075 20.125 12.285V5.90625L11.5 2.86875L2.875 5.90625V12.285C2.875 15.0075 3.68958 17.4825 5.31875 19.71C6.94792 21.9375 9.00833 23.4225 11.5 24.165Z" fill="#943700"/></svg>';

  static const check =
      '<svg width="11" height="9" viewBox="0 0 11 9" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3.8 8.01667L0 4.21667L0.95 3.26667L3.8 6.11667L9.91667 0L10.8667 0.95L3.8 8.01667Z" fill="white"/></svg>';

  static const mic =
      '<svg width="10" height="13" viewBox="0 0 10 13" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4.66667 8C4.11111 8 3.63889 7.80556 3.25 7.41667C2.86111 7.02778 2.66667 6.55556 2.66667 6V2C2.66667 1.44444 2.86111 0.972222 3.25 0.583333C3.63889 0.194444 4.11111 0 4.66667 0C5.22222 0 5.69444 0.194444 6.08333 0.583333C6.47222 0.972222 6.66667 1.44444 6.66667 2V6C6.66667 6.55556 6.47222 7.02778 6.08333 7.41667C5.69444 7.80556 5.22222 8 4.66667 8ZM4 12.6667V10.6167C2.84444 10.4611 1.88889 9.94444 1.13333 9.06667C0.377778 8.18889 0 7.16667 0 6H1.33333C1.33333 6.92222 1.65833 7.70833 2.30833 8.35833C2.95833 9.00833 3.74444 9.33333 4.66667 9.33333C5.58889 9.33333 6.375 9.00833 7.025 8.35833C7.675 7.70833 8 6.92222 8 6H9.33333C9.33333 7.16667 8.95555 8.18889 8.2 9.06667C7.44444 9.94444 6.48889 10.4611 5.33333 10.6167V12.6667H4Z" fill="#434655"/></svg>';

  static const dashboard =
      '<svg width="17" height="18" viewBox="0 0 17 18" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10 6V0H18V6H10ZM0 10V0H8V10H0ZM10 18V8H18V18H10ZM0 18V12H8V18H0ZM2 8H6V2H2V8ZM12 16H16V10H12V16ZM12 4H16V2H12V4ZM2 16H6V14H2V16Z" fill="#004AC6"/></svg>';

  static const inventory =
      '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 20C2.45 20 1.97917 19.8042 1.5875 19.4125C1.19583 19.0208 1 18.55 1 18V6.725C0.7 6.54167 0.458333 6.30417 0.275 6.0125C0.0916667 5.72083 0 5.38333 0 5V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H18C18.55 0 19.0208 0.195833 19.4125 0.5875C19.8042 0.979167 20 1.45 20 2V5C20 5.38333 19.9083 5.72083 19.725 6.0125C19.5417 6.30417 19.3 6.54167 19 6.725V18C19 18.55 18.8042 19.0208 18.4125 19.4125C18.0208 19.8042 17.55 20 17 20H3ZM3 7V18H17V7H3ZM2 5H18V2H2V5ZM7 12H13V10H7V12Z" fill="#004AC6"/></svg>';

  static const voiceOrderDim =
      '<svg width="18" height="22" viewBox="0 0 18 22" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 22C2.71667 22 2.47917 21.9042 2.2875 21.7125C2.09583 21.5208 2 21.2833 2 21C2 20.7167 2.09583 20.4792 2.2875 20.2875C2.47917 20.0958 2.71667 20 3 20C3.28333 20 3.52083 20.0958 3.7125 20.2875C3.90417 20.4792 4 20.7167 4 21C4 21.2833 3.90417 21.5208 3.7125 21.7125C3.52083 21.9042 3.28333 22 3 22ZM7 22C6.71667 22 6.47917 21.9042 6.2875 21.7125C6.09583 21.5208 6 21.2833 6 21C6 20.7167 6.09583 20.4792 6.2875 20.2875C6.47917 20.0958 6.71667 20 7 20C7.28333 20 7.52083 20.0958 7.7125 20.2875C7.90417 20.4792 8 20.7167 8 21C8 21.2833 7.90417 21.5208 7.7125 21.7125C7.52083 21.9042 7.28333 22 7 22ZM11 22C10.7167 22 10.4792 21.9042 10.2875 21.7125C10.0958 21.5208 10 21.2833 10 21C10 20.7167 10.0958 20.4792 10.2875 20.2875C10.4792 20.0958 10.7167 20 11 20C11.2833 20 11.5208 20.0958 11.7125 20.2875C11.9042 20.4792 12 20.7167 12 21C12 21.2833 11.9042 21.5208 11.7125 21.7125C11.5208 21.9042 11.2833 22 11 22ZM7 12C6.16667 12 5.45833 11.7083 4.875 11.125C4.29167 10.5417 4 9.83333 4 9V3C4 2.16667 4.29167 1.45833 4.875 0.875C5.45833 0.291667 6.16667 0 7 0C7.83333 0 8.54167 0.291667 9.125 0.875C9.70833 1.45833 10 2.16667 10 3V9C10 9.83333 9.70833 10.5417 9.125 11.125C8.54167 11.7083 7.83333 12 7 12ZM6 19V15.9C4.26667 15.6667 2.83333 14.8958 1.7 13.5875C0.566667 12.2792 0 10.75 0 9H2C2 10.3833 2.4875 11.5625 3.4625 12.5375C4.4375 13.5125 5.61667 14 7 14C8.38333 14 9.5625 13.5125 10.5375 12.5375C11.5125 11.5625 12 10.3833 12 9H14C14 10.75 13.4333 12.2792 12.3 13.5875C11.1667 14.8958 9.73333 15.6667 8 15.9V19H6ZM7 10C7.28333 10 7.52083 9.90417 7.7125 9.7125C7.90417 9.52083 8 9.28333 8 9V3C8 2.71667 7.90417 2.47917 7.7125 2.2875C7.52083 2.09583 7.28333 2 7 2C6.71667 2 6.47917 2.09583 6.2875 2.2875C6.09583 2.47917 6 2.71667 6 3V9C6 9.28333 6.09583 9.52083 6.2875 9.7125C6.47917 9.90417 6.71667 10 7 10Z" fill="#434655" fill-opacity="0.4"/></svg>';

  static const checkoutDim =
      '<svg width="22" height="20" viewBox="0 0 22 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M11 8L9.6 6.6L11.175 5H7V3H11.175L9.575 1.4L11 0L15 4L11 8ZM6 20C5.45 20 4.97917 19.8042 4.5875 19.4125C4.19583 19.0208 4 18.55 4 18C4 17.45 4.19583 16.9792 4.5875 16.5875C4.97917 16.1958 5.45 16 6 16C6.55 16 7.02083 16.1958 7.4125 16.5875C7.80417 16.9792 8 17.45 8 18C8 18.55 7.80417 19.0208 7.4125 19.4125C7.02083 19.8042 6.55 20 6 20ZM16 20C15.45 20 14.9792 19.8042 14.5875 19.4125C14.1958 19.0208 14 18.55 14 18C14 17.45 14.1958 16.9792 14.5875 16.5875C14.9792 16.1958 15.45 16 16 16C16.55 16 17.0208 16.1958 17.4125 16.5875C17.8042 16.9792 18 17.45 18 18C18 18.55 17.8042 19.0208 17.4125 19.4125C17.0208 19.8042 16.55 20 16 20ZM0 2V0H3.275L7.525 9H14.525L18.425 2H20.7L16.3 9.95C16.1167 10.2833 15.8708 10.5417 15.5625 10.725C15.2542 10.9083 14.9167 11 14.55 11H7.1L6 13H18V15H6C5.25 15 4.67917 14.675 4.2875 14.025C3.89583 13.375 3.88333 12.7167 4.25 12.05L5.6 9.6L2 2H0Z" fill="#434655" fill-opacity="0.4"/></svg>';

  static const lock =
      '<svg width="12" height="16" viewBox="0 0 12 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1.5 15.75C1.0875 15.75 0.734375 15.6031 0.440625 15.3094C0.146875 15.0156 0 14.6625 0 14.25V6.75C0 6.3375 0.146875 5.98438 0.440625 5.69063C0.734375 5.39688 1.0875 5.25 1.5 5.25H2.25V3.75C2.25 2.7125 2.61562 1.82812 3.34687 1.09687C4.07812 0.365625 4.9625 0 6 0C7.0375 0 7.92188 0.365625 8.65312 1.09687C9.38437 1.82812 9.75 2.7125 9.75 3.75V5.25H10.5C10.9125 5.25 11.2656 5.39688 11.5594 5.69063C11.8531 5.98438 12 6.3375 12 6.75V14.25C12 14.6625 11.8531 15.0156 11.5594 15.3094C11.2656 15.6031 10.9125 15.75 10.5 15.75H1.5ZM1.5 14.25H10.5V6.75H1.5V14.25ZM6 12C6.4125 12 6.76562 11.8531 7.05937 11.5594C7.35312 11.2656 7.5 10.9125 7.5 10.5C7.5 10.0875 7.35312 9.73438 7.05937 9.44063C6.76562 9.14688 6.4125 9 6 9C5.5875 9 5.23438 9.14688 4.94063 9.44063C4.64688 9.73438 4.5 10.0875 4.5 10.5C4.5 10.9125 4.64688 11.2656 4.94063 11.5594C5.23438 11.8531 5.5875 12 6 12ZM3.75 5.25H8.25V3.75C8.25 3.125 8.03125 2.59375 7.59375 2.15625C7.15625 1.71875 6.625 1.5 6 1.5C5.375 1.5 4.84375 1.71875 4.40625 2.15625C3.96875 2.59375 3.75 3.125 3.75 3.75V5.25ZM1.5 14.25V6.75V14.25Z" fill="#434655" fill-opacity="0.4"/></svg>';

  static const arrowLeft =
      '<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3.1875 7.5L7.85417 12.1667L6.66667 13.3333L0 6.66667L6.66667 0L7.85417 1.16667L3.1875 5.83333H13.3333V7.5H3.1875Z" fill="#EEEFFF"/></svg>';

  static const infoCircle =
      '<svg width="17" height="17" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.5 12.5H9.16667V7.5H7.5V12.5ZM8.33333 5.83333C8.56944 5.83333 8.76736 5.75347 8.92708 5.59375C9.08681 5.43403 9.16667 5.23611 9.16667 5C9.16667 4.76389 9.08681 4.56597 8.92708 4.40625C8.76736 4.24653 8.56944 4.16667 8.33333 4.16667C8.09722 4.16667 7.89931 4.24653 7.73958 4.40625C7.57986 4.56597 7.5 4.76389 7.5 5C7.5 5.23611 7.57986 5.43403 7.73958 5.59375C7.89931 5.75347 8.09722 5.83333 8.33333 5.83333ZM8.33333 16.6667C7.18056 16.6667 6.09722 16.4479 5.08333 16.0104C4.06944 15.5729 3.1875 14.9792 2.4375 14.2292C1.6875 13.4792 1.09375 12.5972 0.65625 11.5833C0.21875 10.5694 0 9.48611 0 8.33333C0 7.18056 0.21875 6.09722 0.65625 5.08333C1.09375 4.06944 1.6875 3.1875 2.4375 2.4375C3.1875 1.6875 4.06944 1.09375 5.08333 0.65625C6.09722 0.21875 7.18056 0 8.33333 0C9.48611 0 10.5694 0.21875 11.5833 0.65625C12.5972 1.09375 13.4792 1.6875 14.2292 2.4375C14.9792 3.1875 15.5729 4.06944 16.0104 5.08333C16.4479 6.09722 16.6667 7.18056 16.6667 8.33333C16.6667 9.48611 16.4479 10.5694 16.0104 11.5833C15.5729 12.5972 14.9792 13.4792 14.2292 14.2292C13.4792 14.9792 12.5972 15.5729 11.5833 16.0104C10.5694 16.4479 9.48611 16.6667 8.33333 16.6667ZM8.33333 15C10.1944 15 11.7708 14.3542 13.0625 13.0625C14.3542 11.7708 15 10.1944 15 8.33333C15 6.47222 14.3542 4.89583 13.0625 3.60417C11.7708 2.3125 10.1944 1.66667 8.33333 1.66667C6.47222 1.66667 4.89583 2.3125 3.60417 3.60417C2.3125 4.89583 1.66667 6.47222 1.66667 8.33333C1.66667 10.1944 2.3125 11.7708 3.60417 13.0625C4.89583 14.3542 6.47222 15 8.33333 15Z" fill="#004AC6"/></svg>';

  static const help =
      '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M9.95 16C10.3 16 10.5958 15.8792 10.8375 15.6375C11.0792 15.3958 11.2 15.1 11.2 14.75C11.2 14.4 11.0792 14.1042 10.8375 13.8625C10.5958 13.6208 10.3 13.5 9.95 13.5C9.6 13.5 9.30417 13.6208 9.0625 13.8625C8.82083 14.1042 8.7 14.4 8.7 14.75C8.7 15.1 8.82083 15.3958 9.0625 15.6375C9.30417 15.8792 9.6 16 9.95 16ZM9.05 12.15H10.9C10.9 11.6 10.9625 11.1667 11.0875 10.85C11.2125 10.5333 11.5667 10.1 12.15 9.55C12.5833 9.11667 12.925 8.70417 13.175 8.3125C13.425 7.92083 13.55 7.45 13.55 6.9C13.55 5.96667 13.2083 5.25 12.525 4.75C11.8417 4.25 11.0333 4 10.1 4C9.15 4 8.37917 4.25 7.7875 4.75C7.19583 5.25 6.78333 5.85 6.55 6.55L8.2 7.2C8.28333 6.9 8.47083 6.575 8.7625 6.225C9.05417 5.875 9.5 5.7 10.1 5.7C10.6333 5.7 11.0333 5.84583 11.3 6.1375C11.5667 6.42917 11.7 6.75 11.7 7.1C11.7 7.43333 11.6 7.74583 11.4 8.0375C11.2 8.32917 10.95 8.6 10.65 8.85C9.91667 9.5 9.46667 9.99167 9.3 10.325C9.13333 10.6583 9.05 11.2667 9.05 12.15ZM10 20C8.61667 20 7.31667 19.7375 6.1 19.2125C4.88333 18.6875 3.825 17.975 2.925 17.075C2.025 16.175 1.3125 15.1167 0.7875 13.9C0.2625 12.6833 0 11.3833 0 10C0 8.61667 0.2625 7.31667 0.7875 6.1C1.3125 4.88333 2.025 3.825 2.925 2.925C3.825 2.025 4.88333 1.3125 6.1 0.7875C7.31667 0.2625 8.61667 0 10 0C11.3833 0 12.6833 0.2625 13.9 0.7875C15.1167 1.3125 16.175 2.025 17.075 2.925C17.975 3.825 18.6875 4.88333 19.2125 6.1C19.7375 7.31667 20 8.61667 20 10C20 11.3833 19.7375 12.6833 19.2125 13.9C18.6875 15.1167 17.975 16.175 17.075 17.075C16.175 17.975 15.1167 18.6875 13.9 19.2125C12.6833 19.7375 11.3833 20 10 20ZM10 18C12.2333 18 14.125 17.225 15.675 15.675C17.225 14.125 18 12.2333 18 10C18 7.76667 17.225 5.875 15.675 4.325C14.125 2.775 12.2333 2 10 2C7.76667 2 5.875 2.775 4.325 4.325C2.775 5.875 2 7.76667 2 10C2 12.2333 2.775 14.125 4.325 15.675C5.875 17.225 7.76667 18 10 18Z" fill="#434655"/></svg>';

  static const bell =
      '<svg width="16" height="20" viewBox="0 0 16 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0 17V15H2V8C2 6.61667 2.41667 5.3875 3.25 4.3125C4.08333 3.2375 5.16667 2.53333 6.5 2.2V1.5C6.5 1.08333 6.64583 0.729167 6.9375 0.4375C7.22917 0.145833 7.58333 0 8 0C8.41667 0 8.77083 0.145833 9.0625 0.4375C9.35417 0.729167 9.5 1.08333 9.5 1.5V2.2C10.8333 2.53333 11.9167 3.2375 12.75 4.3125C13.5833 5.3875 14 6.61667 14 8V15H16V17H0ZM8 20C7.45 20 6.97917 19.8042 6.5875 19.4125C6.19583 19.0208 6 18.55 6 18H10C10 18.55 9.80417 19.0208 9.4125 19.4125C9.02083 19.8042 8.55 20 8 20ZM4 15H12V8C12 6.9 11.6083 5.95833 10.825 5.175C10.0417 4.39167 9.1 4 8 4C6.9 4 5.95833 4.39167 5.175 5.175C4.39167 5.95833 4 6.9 4 8V15Z" fill="#434655"/></svg>';
}

class RegistrationSubmittedScreen extends StatelessWidget {
  const RegistrationSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegistrationSubmittedController());

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(24.w, 46.h, 24.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedEntrance(
                      child: Text(
                        'تم تسجيل المنشأة بنجاح',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _C.textDark,
                          fontFamily: 'Cairo',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.5.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 60),
                      child: SizedBox(
                        width: 280.w,
                        child: Text(
                          'تم تسجيل متجرك بنجاح في منصة سلاسل.\nنقوم الآن بمراجعة بياناتك.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _C.textBody,
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            height: 1.86.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 120),
                      child: AspectRatio(
                        aspectRatio: 363 / 272,
                        child: CachedNetworkImage(
                          imageUrl: _kIllustrationUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 180),
                      beginOffset: const Offset(0, 0.1),
                      child: _VerificationStatusCard(controller: controller),
                    ),
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 260),
                      beginOffset: const Offset(0, 0.1),
                      child: _BentoGrid(),
                    ),
                    SizedBox(height: 24.h),
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 340),
                      beginOffset: const Offset(0, 0.1),
                      child: _ActionButtons(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 0,
          isSetupMode: true,
          onTap: (index) {
            if (index == 0) {
              // They are already on the setup/store screen, do nothing.
            } else {
              Get.snackbar('مقفل مؤقتاً', 'ستُفتح هذه الميزة عند اكتمال توثيق السجل التجاري');
            }
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 64.h + topInset,
          padding: EdgeInsets.only(top: topInset, left: 20.w, right: 20.w),
          color: Colors.white.withValues(alpha: 0.8),
          child: Row(
            children: [
              AnimatedPressable(
                borderRadius: BorderRadius.circular(9999.r),
                onTap: () => Get.snackbar('مركز المساعدة', 'الدعم الفني متاح قريباً'),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: SvgPicture.string(_Svg.help, width: 20.w, height: 20.h),
                ),
              ),
              SizedBox(width: 20.w),
              AnimatedPressable(
                borderRadius: BorderRadius.circular(9999.r),
                onTap: () => Get.snackbar('الإشعارات', 'لا توجد إشعارات جديدة حالياً'),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: SvgPicture.string(_Svg.bell, width: 16.w, height: 20.h),
                ),
              ),
              const Spacer(),
              CachedNetworkImage(imageUrl: _kLogoUrl, width: 70.w, height: 47.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationStatusCard extends StatelessWidget {
  final RegistrationSubmittedController controller;

  const _VerificationStatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(color: _C.pendingBg, borderRadius: BorderRadius.circular(9999.r)),
                child: Text(
                  'معلق',
                  style: TextStyle(color: _C.pendingText, fontFamily: 'Cairo', fontSize: 12.sp, fontWeight: FontWeight.w700, height: 1.33.h),
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('توثيق السجل التجاري',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: _C.textDark, fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, height: 1.5.h)),
                      Text('قيد المراجعة',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: _C.pendingText, fontFamily: 'Cairo', fontSize: 12.sp, fontWeight: FontWeight.w700, height: 1.5.h)),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Center(child: SvgPicture.string(_Svg.shieldCheck, width: 23.w, height: 27.h)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _C.surfaceGray,
              border: Border.all(color: _C.borderGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: 'تستغرق عملية المراجعة عادةً من ', style: TextStyle(color: _C.textBody, fontFamily: 'Cairo', fontSize: 12.sp, height: 1.9.h)),
                    TextSpan(text: '24 إلى 48 ساعة', style: TextStyle(color: _C.textDark, fontFamily: 'Cairo', fontSize: 12.sp, fontWeight: FontWeight.w700, height: 1.9.h)),
                    TextSpan(text: '.', style: TextStyle(color: _C.textDark, fontFamily: 'Cairo', fontSize: 12.sp, height: 1.9.h)),
                  ]),
                  textAlign: TextAlign.right,
                ),
                Text(
                  'ميزة الطلب الصوتي والتعميد المباشر ستكون مقفلة حتى إتمام التوثيق.',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: _C.textBody, fontFamily: 'Cairo', fontSize: 12.sp, height: 1.9.h),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final String subDate = controller.submissionDate.value;
            final String subtitle = subDate.isNotEmpty ? 'تم الاستلام في $subDate' : 'جاري التحميل...';
            return Column(
              children: [
                _TimelineRow(title: 'تقديم طلب التسجيل', subtitle: subtitle, state: _StepState.done, bold: true),
                _TimelineRow(title: 'مراجعة المستندات (جاري)', state: _StepState.active, bold: true),
                _TimelineRow(title: 'الموافقة النهائية', state: _StepState.pending, dimmed: true),
                _TimelineRow(title: 'تفعيل الشراء الصوتي', state: _StepState.pending, dimmed: true, showMic: true, isLast: true),
              ],
            );
          }),
        ],
      ),
    );
  }
}

enum _StepState { done, active, pending }

class _TimelineRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final _StepState state;
  final bool bold;
  final bool dimmed;
  final bool showMic;
  final bool isLast;

  const _TimelineRow({
    required this.title,
    this.subtitle,
    required this.state,
    this.bold = false,
    this.dimmed = false,
    this.showMic = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget bullet;
    switch (state) {
      case _StepState.done:
        bullet = Container(
          width: 24.w,
          height: 24.h,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: _C.primaryBlue, shape: BoxShape.circle),
          child: SvgPicture.string(_Svg.check, width: 11.w, height: 9.h),
        );
        break;
      case _StepState.active:
        bullet = Container(
          width: 24.w,
          height: 24.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: _C.primaryBlue, width: 2.w)),
          child: Container(width: 8.w, height: 8.h, decoration: const BoxDecoration(color: _C.primaryBlue, shape: BoxShape.circle)),
        );
        break;
      case _StepState.pending:
        bullet = Container(
          width: 24.w,
          height: 24.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: _C.dimGray, width: 2.w)),
          child: showMic ? SvgPicture.string(_Svg.mic, width: 10.w, height: 13.h) : null,
        );
        break;
    }

    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _C.textDark,
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                    height: 1.43.h,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      subtitle!,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _C.textBody,
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        height: 1.4.h,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16.w),
            Column(
              children: [
                bullet,
                if (!isLast)
                  Container(
                    width: 2.w,
                    height: 32.h,
                    color: state == _StepState.done ? _C.primaryBlue : _C.dimGray,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  void _snack(String title, String msg) => Get.snackbar(title, msg);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 165 / 86,
      children: [
        _bentoCard(icon: _Svg.inventory, iconSize: const Size(20, 20), label: 'تصفح المخزون', enabled: true, hasBorder: false, onTap: () => Get.offAll(() => const HomeScreen(), transition: Transition.fadeIn)),
        _bentoCard(icon: _Svg.dashboard, iconSize: const Size(17, 18), label: 'لوحة التحكم', enabled: true, hasBorder: false, onTap: () => _snack('لوحة التحكم', 'قريباً')),
        _bentoCard(icon: _Svg.checkoutDim, iconSize: const Size(22, 20), label: 'إتمام الشراء', enabled: false, hasBorder: true, onTap: () => _snack('مقفل مؤقتاً', 'ستُفتح هذه الميزة عند اكتمال توثيق السجل التجاري')),
        _bentoCard(icon: _Svg.voiceOrderDim, iconSize: const Size(18, 22), label: 'الطلب الصوتي', enabled: false, hasBorder: false, onTap: () => _snack('مقفل مؤقتاً', 'ستُفتح هذه الميزة عند اكتمال توثيق السجل التجاري')),
      ],
    );
  }

  Widget _bentoCard({
    required String icon,
    required Size iconSize,
    required String label,
    required bool enabled,
    required bool hasBorder,
    required VoidCallback onTap,
  }) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        clipBehavior: enabled ? Clip.none : Clip.antiAlias,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : _C.lockedBg,
          borderRadius: BorderRadius.circular(8.r),
          border: hasBorder ? Border.all(color: _C.borderGray) : null,
          boxShadow: enabled
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.string(icon, width: iconSize.width.w, height: iconSize.height.h),
                    SizedBox(height: 8.h),
                    Text(
                      label,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: enabled ? _C.textDark : _C.mutedIcon,
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: enabled ? FontWeight.w700 : FontWeight.w400,
                        height: 1.43.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!enabled)
              Positioned(
                left: -8.w,
                top: -6.h,
                child: SvgPicture.string(_Svg.lock, width: 12.w, height: 16.h),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedPressable(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () => Get.offAll(() => const HomeScreen(), transition: Transition.fadeIn),
          child: Container(
            width: double.infinity,
            height: 56.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _C.ctaBlue, borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(_Svg.arrowLeft, width: 14.w, height: 14.h),
                SizedBox(width: 8.w),
                Text('الذهاب للرئيسية',
                    style: TextStyle(color: const Color(0xFFEEEFFF), fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, height: 1.5.h)),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedPressable(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () => Get.to(() => const OnboardingScreen(), transition: Transition.fadeIn),
          child: Container(
            width: double.infinity,
            height: 56.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: const Color(0x33004AC6))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('كيف يعمل الطلب الصوتي؟',
                    style: TextStyle(color: _C.primaryBlue, fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, height: 1.5.h)),
                SizedBox(width: 8.w),
                SvgPicture.string(_Svg.infoCircle, width: 17.w, height: 17.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
