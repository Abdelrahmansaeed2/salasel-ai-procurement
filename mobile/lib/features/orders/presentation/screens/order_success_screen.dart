import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../theme/order_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _Icons {
  static const checkmark =
      '<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M10 24L20 35L38 14" stroke="white" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const copy =
      '<svg width="13" height="13" viewBox="0 0 13 13" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M10.8333 4.3335H5.41659C4.81828 4.3335 4.33325 4.81852 4.33325 5.41683V10.8335C4.33325 11.4318 4.81828 11.9168 5.41659 11.9168H10.8333C11.4316 11.9168 11.9166 11.4318 11.9166 10.8335V5.41683C11.9166 4.81852 11.4316 4.3335 10.8333 4.3335Z" stroke="#90A1B9" stroke-width="1.08333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M2.16659 8.66683C1.57075 8.66683 1.08325 8.17933 1.08325 7.5835V2.16683C1.08325 1.571 1.57075 1.0835 2.16659 1.0835H7.58325C8.17909 1.0835 8.66659 1.571 8.66659 2.16683" stroke="#90A1B9" stroke-width="1.08333" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const checkCircle =
      '<svg width="11" height="11" viewBox="0 0 11 11" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M5.49996 10.0832C8.03126 10.0832 10.0833 8.03114 10.0833 5.49984C10.0833 2.96853 8.03126 0.916504 5.49996 0.916504C2.96865 0.916504 0.916626 2.96853 0.916626 5.49984C0.916626 8.03114 2.96865 10.0832 5.49996 10.0832Z" stroke="#22C55E" stroke-width="0.916667" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M4.125 5.50016L5.04167 6.41683L6.875 4.5835" stroke="#22C55E" stroke-width="0.916667" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const starFilled =
      '<svg width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M4.80202 0.956368C4.82028 0.919477 4.84849 0.888424 4.88346 0.866712C4.91843 0.845001 4.95877 0.833496 4.99994 0.833496C5.0411 0.833496 5.08144 0.845001 5.11641 0.866712C5.15139 0.888424 5.17959 0.919477 5.19785 0.956368L6.16035 2.90595C6.22376 3.03427 6.31736 3.14529 6.43311 3.22947C6.54887 3.31366 6.68332 3.3685 6.82494 3.38929L8.97744 3.70429C9.01822 3.71019 9.05654 3.7274 9.08806 3.75395C9.11957 3.7805 9.14303 3.81535 9.15578 3.85454C9.16852 3.89373 9.17005 3.9357 9.16018 3.97572C9.15031 4.01573 9.12944 4.05218 9.09994 4.08095L7.54327 5.59679C7.44061 5.69683 7.3638 5.82032 7.31945 5.95663C7.2751 6.09294 7.26454 6.23799 7.28869 6.37929L7.65619 8.52095C7.66339 8.56172 7.65898 8.60369 7.64348 8.64207C7.62797 8.68045 7.60199 8.71371 7.5685 8.73803C7.535 8.76236 7.49534 8.77678 7.45405 8.77966C7.41275 8.78253 7.37148 8.77374 7.33494 8.75428L5.41077 7.74262C5.28399 7.67605 5.14293 7.64126 4.99973 7.64126C4.85653 7.64126 4.71547 7.67605 4.58869 7.74262L2.66494 8.75428C2.62841 8.77362 2.58719 8.78232 2.54596 8.77939C2.50473 8.77646 2.46515 8.76202 2.43173 8.73771C2.3983 8.7134 2.37237 8.6802 2.35688 8.64188C2.34139 8.60356 2.33696 8.56166 2.3441 8.52095L2.71119 6.3797C2.73543 6.23834 2.72493 6.0932 2.68058 5.9568C2.63622 5.82041 2.55936 5.69685 2.4566 5.59679L0.899936 4.08137C0.870184 4.05263 0.8491 4.01612 0.839087 3.97598C0.829074 3.93585 0.830535 3.89371 0.843302 3.85436C0.85607 3.81502 0.879631 3.78005 0.911301 3.75344C0.942972 3.72684 0.981479 3.70966 1.02244 3.70387L3.17452 3.38929C3.31629 3.36866 3.45093 3.31389 3.56685 3.2297C3.68276 3.1455 3.77648 3.0344 3.83994 2.90595L4.80202 0.956368Z" fill="#FCD34D" stroke="#FDC700" stroke-width="0.833333" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const starOutline =
      '<svg width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M4.80202 0.956368C4.82028 0.919477 4.84849 0.888424 4.88346 0.866712C4.91843 0.845001 4.95877 0.833496 4.99994 0.833496C5.0411 0.833496 5.08144 0.845001 5.11641 0.866712C5.15139 0.888424 5.17959 0.919477 5.19785 0.956368L6.16035 2.90595C6.22376 3.03427 6.31736 3.14529 6.43311 3.22947C6.54887 3.31366 6.68332 3.3685 6.82494 3.38929L8.97744 3.70429C9.01822 3.71019 9.05654 3.7274 9.08806 3.75395C9.11957 3.7805 9.14303 3.81535 9.15578 3.85454C9.16852 3.89373 9.17005 3.9357 9.16018 3.97572C9.15031 4.01573 9.12944 4.05218 9.09994 4.08095L7.54327 5.59679C7.44061 5.69683 7.3638 5.82032 7.31945 5.95663C7.2751 6.09294 7.26454 6.23799 7.28869 6.37929L7.65619 8.52095C7.66339 8.56172 7.65898 8.60369 7.64348 8.64207C7.62797 8.68045 7.60199 8.71371 7.5685 8.73803C7.535 8.76236 7.49534 8.77678 7.45405 8.77966C7.41275 8.78253 7.37148 8.77374 7.33494 8.75428L5.41077 7.74262C5.28399 7.67605 5.14293 7.64126 4.99973 7.64126C4.85653 7.64126 4.71547 7.67605 4.58869 7.74262L2.66494 8.75428C2.62841 8.77362 2.58719 8.78232 2.54596 8.77939C2.50473 8.77646 2.46515 8.76202 2.43173 8.73771C2.3983 8.7134 2.37237 8.6802 2.35688 8.64188C2.34139 8.60356 2.33696 8.56166 2.3441 8.52095L2.71119 6.3797C2.73543 6.23834 2.72493 6.0932 2.68058 5.9568C2.63622 5.82041 2.55936 5.69685 2.4566 5.59679L0.899936 4.08137C0.870184 4.05263 0.8491 4.01612 0.839087 3.97598C0.829074 3.93585 0.830535 3.89371 0.843302 3.85436C0.85607 3.81502 0.879631 3.78005 0.911301 3.75344C0.942972 3.72684 0.981479 3.70966 1.02244 3.70387L3.17452 3.38929C3.31629 3.36866 3.45093 3.31389 3.56685 3.2297C3.68276 3.1455 3.77648 3.0344 3.83994 2.90595L4.80202 0.956368Z" stroke="#CAD5E2" stroke-width="0.833333" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const stepBox =
      '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M7.33333 14.4864C7.53603 14.6035 7.76595 14.6651 8 14.6651C8.23405 14.6651 8.46397 14.6035 8.66667 14.4864L13.3333 11.8198C13.5358 11.7029 13.704 11.5348 13.821 11.3323C13.938 11.1299 13.9998 10.9003 14 10.6664V5.33311C13.9998 5.09929 13.938 4.86965 13.821 4.66721C13.704 4.46478 13.5358 4.29668 13.3333 4.17977L8.66667 1.51311C8.46397 1.39608 8.23405 1.33447 8 1.33447C7.76595 1.33447 7.53603 1.39608 7.33333 1.51311L2.66667 4.17977C2.46418 4.29668 2.29599 4.46478 2.17897 4.66721C2.06196 4.86965 2.00024 5.09929 2 5.33311V10.6664C2.00024 10.9003 2.06196 11.1299 2.17897 11.3323C2.29599 11.5348 2.46418 11.7029 2.66667 11.8198L7.33333 14.4864Z" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M8 14.6667V8" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M2.19336 4.6665L8.00003 7.99984L13.8067 4.6665" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M5 2.84668L11 6.28001" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const stepTruck =
      '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M9.33342 2H2.00008C1.2637 2 0.666748 2.59695 0.666748 3.33333V9.33333C0.666748 10.0697 1.2637 10.6667 2.00008 10.6667H9.33342C10.0698 10.6667 10.6667 10.0697 10.6667 9.33333V3.33333C10.6667 2.59695 10.0698 2 9.33342 2Z" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M10.6667 5.3335H13.3334L15.3334 7.3335V10.6668H10.6667V5.3335Z" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M3.66667 13.9998C4.58714 13.9998 5.33333 13.2536 5.33333 12.3332C5.33333 11.4127 4.58714 10.6665 3.66667 10.6665C2.74619 10.6665 2 11.4127 2 12.3332C2 13.2536 2.74619 13.9998 3.66667 13.9998Z" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M12.3334 13.9998C13.2539 13.9998 14.0001 13.2536 14.0001 12.3332C14.0001 11.4127 13.2539 10.6665 12.3334 10.6665C11.4129 10.6665 10.6667 11.4127 10.6667 12.3332C10.6667 13.2536 11.4129 13.9998 12.3334 13.9998Z" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const stepPin =
      '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M8.40075 14.5328C9.64075 13.4622 13.3334 9.9955 13.3334 6.66683C13.3334 5.25234 12.7715 3.89579 11.7713 2.89559C10.7711 1.8954 9.41457 1.3335 8.00008 1.3335C6.58559 1.3335 5.22904 1.8954 4.22885 2.89559C3.22865 3.89579 2.66675 5.25234 2.66675 6.66683C2.66675 9.9955 6.35941 13.4622 7.59941 14.5328C7.71493 14.6197 7.85555 14.6667 8.00008 14.6667C8.14461 14.6667 8.28523 14.6197 8.40075 14.5328Z" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M8 8.6665C9.10457 8.6665 10 7.77107 10 6.6665C10 5.56193 9.10457 4.6665 8 4.6665C6.89543 4.6665 6 5.56193 6 6.6665C6 7.77107 6.89543 8.6665 8 8.6665Z" stroke="{{c}}" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const track =
      '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M10 20C8.61667 20 7.31667 19.7375 6.1 19.2125C4.88333 18.6875 3.825 17.975 2.925 17.075C2.025 16.175 1.3125 15.1167 0.7875 13.9C0.2625 12.6833 0 11.3833 0 10C0 8.61667 0.2625 7.31667 0.7875 6.1C1.3125 4.88333 2.025 3.825 2.925 2.925C3.825 2.025 4.88333 1.3125 6.1 0.7875C7.31667 0.2625 8.61667 0 10 0H11V8.275C11.3 8.45833 11.5417 8.69583 11.725 8.9875C11.9083 9.27917 12 9.61667 12 10C12 10.55 11.8042 11.0208 11.4125 11.4125C11.0208 11.8042 10.55 12 10 12C9.45 12 8.97917 11.8042 8.5875 11.4125C8.19583 11.0208 8 10.55 8 10C8 9.61667 8.09167 9.275 8.275 8.975C8.45833 8.675 8.7 8.44167 9 8.275V6.125C8.13333 6.35833 7.41667 6.82917 6.85 7.5375C6.28333 8.24583 6 9.06667 6 10C6 11.1 6.39167 12.0417 7.175 12.825C7.95833 13.6083 8.9 14 10 14C11.1 14 12.0417 13.6083 12.825 12.825C13.6083 12.0417 14 11.1 14 10C14 9.4 13.8792 8.84583 13.6375 8.3375C13.3958 7.82917 13.0667 7.38333 12.65 7L14.075 5.575C14.6583 6.125 15.125 6.77917 15.475 7.5375C15.825 8.29583 16 9.11667 16 10C16 11.6667 15.4167 13.0833 14.25 14.25C13.0833 15.4167 11.6667 16 10 16C8.33333 16 6.91667 15.4167 5.75 14.25C4.58333 13.0833 4 11.6667 4 10C4 8.5 4.475 7.19583 5.425 6.0875C6.375 4.97917 7.56667 4.30833 9 4.075V2.05C7.01667 2.3 5.35417 3.175 4.0125 4.675C2.67083 6.175 2 7.95 2 10C2 12.2333 2.775 14.125 4.325 15.675C5.875 17.225 7.76667 18 10 18C12.2333 18 14.125 17.225 15.675 15.675C17.225 14.125 18 12.2333 18 10C18 8.85 17.775 7.775 17.325 6.775C16.875 5.775 16.2583 4.90833 15.475 4.175L16.9 2.75C17.85 3.66667 18.6042 4.74583 19.1625 5.9875C19.7208 7.22917 20 8.56667 20 10C20 11.3833 19.7375 12.6833 19.2125 13.9C18.6875 15.1167 17.975 16.175 17.075 17.075C16.175 17.975 15.1167 18.6875 13.9 19.2125C12.6833 19.7375 11.3833 20 10 20Z" fill="#EEEFFF"/></svg>';

  static const home =
      '<svg width="16" height="18" viewBox="0 0 16 18" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M2 16H5V10H11V16H14V7L8 2.5L2 7V16ZM0 18V6L8 0L16 6V18H9V12H7V18H0Z" fill="#191B23"/></svg>';
}

class TimelineEvent {
  final String time;
  final String title;
  final String subtitle;
  final String iconSvgTemplate;
  final bool isActive;
  final bool isDone;

  TimelineEvent({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.iconSvgTemplate,
    this.isActive = false,
    this.isDone = false,
  });
}

class OrderSuccessScreen extends StatelessWidget {
  final double totalAmount;
  final int itemCount;
  final String orderId;
  final String supplierName;

  const OrderSuccessScreen({
    super.key,
    required this.totalAmount,
    required this.itemCount,
    required this.orderId,
    required this.supplierName,
  });

  static final List<TimelineEvent> _events = [
    TimelineEvent(
      time: '٦:٠٠ص',
      title: 'قيد التجهيز',
      subtitle: 'تجميع المنتجات في المستودع',
      iconSvgTemplate: _Icons.stepBox,
      isActive: true,
    ),
    TimelineEvent(
      time: '٨:٠٠ص',
      title: 'في الطريق إليك',
      subtitle: 'خروج من مستودع الرياض',
      iconSvgTemplate: _Icons.stepTruck,
    ),
    TimelineEvent(
      time: '٩:٣٠ص',
      title: 'تم التوصيل',
      subtitle: 'بقالة النور · الرياض',
      iconSvgTemplate: _Icons.stepPin,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 48.h),
                _buildSuccessOrb(),
                SizedBox(height: 20.h),
                AnimatedEntrance(
                  delay: Duration(milliseconds: 250),
                  child: Text(
                    'تم إرسال الطلب! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F172B),
                      fontFamily: 'Cairo',
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.25.h,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                AnimatedEntrance(
                  delay: Duration(milliseconds: 300),
                  child: Text(
                    'طلبك وصل إلى المورد وسيتم تأكيده خلال دقائق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OrderColors.textMuted,
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      height: 1.625.h,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                AnimatedEntrance(
                  delay: Duration(milliseconds: 350),
                  child: Center(child: _buildOrderIdChip()),
                ),
                SizedBox(height: 20.h),
                AnimatedEntrance(
                  delay: Duration(milliseconds: 400),
                  beginOffset: Offset(0, 0.15),
                  child: _buildSummaryBar(),
                ),
                SizedBox(height: 24.h),
                AnimatedEntrance(
                  delay: Duration(milliseconds: 460),
                  beginOffset: Offset(0, 0.15),
                  child: _buildSupplierTimelineCard(),
                ),
                SizedBox(height: 24.h),
                AnimatedEntrance(
                  delay: Duration(milliseconds: 520),
                  child: _buildTipBanner(),
                ),
                SizedBox(height: 16.h),
                AnimatedEntrance(
                  delay: Duration(milliseconds: 580),
                  child: _buildActions(),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOrb() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          width: 112.w,
          height: 112.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
            ),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) => Opacity(opacity: value, child: child),
            child: SvgPicture.string(_Icons.checkmark, width: 48.w, height: 48.h),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderIdChip() {
    return _CopyableOrderId(orderId: orderId);
  }

  Widget _buildSummaryBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _summaryItem('${totalAmount.toStringAsFixed(0)} جنيه', 'المبلغ'),
            ),
            VerticalDivider(color: OrderColors.divider, width: 1.w),
            Expanded(
              child: _summaryItem('غداً ٩:٣٠', 'التوصيل', color: OrderColors.primary),
            ),
            VerticalDivider(color: OrderColors.divider, width: 1.w),
            Expanded(
              child: _summaryItem('$itemCount صنف', 'المنتجات', color: OrderColors.success),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String value, String label, {Color color = const Color(0xFF0F172A)}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: OrderColors.textFaint,
              fontFamily: 'Cairo',
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierTimelineCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: OrderColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8FAFF), Color(0xFFEFF6FF)],
              ),
              border: Border(bottom: BorderSide(color: Color(0xFFDBEAFE))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text('🏭', style: TextStyle(fontSize: 20.sp)),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        supplierName,
                        style: TextStyle(
                          color: Color(0xFF0F172B),
                          fontFamily: 'Cairo',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgPicture.string(_Icons.starFilled, width: 10.w, height: 10.h),
                          SvgPicture.string(_Icons.starFilled, width: 10.w, height: 10.h),
                          SvgPicture.string(_Icons.starFilled, width: 10.w, height: 10.h),
                          SvgPicture.string(_Icons.starFilled, width: 10.w, height: 10.h),
                          SvgPicture.string(_Icons.starOutline, width: 10.w, height: 10.h),
                          SizedBox(width: 4.w),
                          Text('٤.٨',
                              style: TextStyle(color: OrderColors.textFaint, fontSize: 10.sp)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'مؤكد',
                        style: TextStyle(
                          color: OrderColors.success,
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      SvgPicture.string(_Icons.checkCircle, width: 11.w, height: 11.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _gridItem(
                          '${totalAmount.toStringAsFixed(2)} جنيه', 'المبلغ الإجمالي'),
                    ),
                    Expanded(child: _gridItem('$itemCount منتج', 'عدد المنتجات')),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _gridItem('آجل ٣٠ يوم', 'طريقة الدفع', color: OrderColors.primary),
                    ),
                    Expanded(child: _gridItem('INV-7821', 'رقم الفاتورة')),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: OrderColors.divider, height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: List.generate(_events.length, (i) {
                final event = _events[i];
                final isLast = i == _events.length - 1;
                return _TimelineStepRow(event: event, isLast: isLast, index: i);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridItem(String value, String label, {Color color = const Color(0xFF0F172A)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(color: OrderColors.textFaint, fontFamily: 'Cairo', fontSize: 10.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTipBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نصيحة سلاسل',
                  style: TextStyle(
                    color: Color(0xFF973C00),
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'ستصلك رسالة واتساب من المورد عند خروج الشحنة. يمكنك تتبع موقع السائق مباشرة.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFFBB4D00),
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    height: 1.625.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
      
        AnimatedPressable(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () => Get.offAll(() => HomeScreen(), transition: Transition.fadeIn),
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: Color(0xFFE7E7F3),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(_Icons.home, width: 16.w, height: 18.h),
                SizedBox(width: 8.w),
                Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    color: Color(0xFF191B23),
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CopyableOrderId extends StatefulWidget {
  final String orderId;
  const _CopyableOrderId({required this.orderId});

  @override
  State<_CopyableOrderId> createState() => _CopyableOrderIdState();
}

class _CopyableOrderIdState extends State<_CopyableOrderId> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.orderId));
    setState(() => _copied = true);
    Get.snackbar('تم النسخ', 'تم نسخ رقم الطلب');
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(14.r),
      onTap: _copy,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: OrderColors.chipBg,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: _copied
                  ? Icon(Icons.check, key: ValueKey('done'), size: 13.w, color: OrderColors.success)
                  : SvgPicture.string(_Icons.copy, key: ValueKey('copy'), width: 13.w, height: 13.h),
            ),
            SizedBox(width: 8.w),
            Text(
              widget.orderId,
              style: TextStyle(
                color: OrderColors.textMuted,
                fontFamily: 'Inter',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStepRow extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;
  final int index;

  const _TimelineStepRow({required this.event, required this.isLast, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = event.isActive ? OrderColors.primary : Color(0xFF94A3B8);
    final bg = event.isActive ? Color(0xFFEFF6FF) : Color(0xFFF1F5F9);
    final border = event.isActive ? Color(0xFFBFDBFE) : Color(0xFFE2E8F0);
    final iconMarkup = event.iconSvgTemplate
        .replaceAll('{{c}}', '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}');

    return AnimatedEntrance(
      delay: Duration(milliseconds: 650 + index * 120),
      beginOffset: Offset(0.05, 0),
      child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                        border: Border.all(color: border),
                      ),
                      child: SvgPicture.string(iconMarkup, width: 16.w, height: 16.h),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 1.w, color: Color(0xFFE2E8F0)),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            color: event.isActive ? Color(0xFF1D4ED8) : Color(0xFF94A3B8),
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          event.time,
                          style: TextStyle(
                            color: event.isActive ? OrderColors.primary : Color(0xFFCBD5E1),
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      event.subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: OrderColors.textFaint,
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
