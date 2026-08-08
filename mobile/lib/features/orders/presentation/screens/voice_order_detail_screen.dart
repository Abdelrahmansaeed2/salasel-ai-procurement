import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class VoiceOrderProduct {
  final String supplier;
  final String name;
  final String detectedQuantity;
  final String requestedQuantity;

  const VoiceOrderProduct({
    required this.supplier,
    required this.name,
    required this.detectedQuantity,
    required this.requestedQuantity,
  });
}

class VoiceOrderDetailScreen extends StatefulWidget {
  final String orderNumber;
  final String deliveryDate;
  final String statusLabel;
  final String transcript;
  final List<VoiceOrderProduct> products;
  final double subtotal;
  final double deliveryFee;
  final double tax;

  const VoiceOrderDetailScreen({
    super.key,
    this.orderNumber = '#SL-94821',
    this.deliveryDate = 'اليوم، 14:30',
    this.statusLabel = 'مكتمل',
    this.transcript = 'محتاج 20 كرتونة حليب، 10 أكياس سكر، و 5 كراتين شاي.',
    this.products = const [
      VoiceOrderProduct(
        supplier: 'Nile Foods',
        name: 'حليب المراعي',
        detectedQuantity: '20 Cartons',
        requestedQuantity: '20 كرتونة',
      ),
      VoiceOrderProduct(
        supplier: 'Delta Trade',
        name: 'سكر الأسرة',
        detectedQuantity: '10 Bags (5kg)',
        requestedQuantity: '10 أكياس',
      ),
      VoiceOrderProduct(
        supplier: 'Nile Foods',
        name: 'شاي ليبتون',
        detectedQuantity: '5 Boxes (100 bags)',
        requestedQuantity: '5 كراتين',
      ),
    ],
    this.subtotal = 650,
    this.deliveryFee = 35,
    this.tax = 0,
  });

  @override
  State<VoiceOrderDetailScreen> createState() =>
      _VoiceOrderDetailScreenState();
}

class _VoiceOrderDetailScreenState extends State<VoiceOrderDetailScreen> {
  bool _isPlaying = false;
  bool _showWhySelected = false;

  double get _total => widget.subtotal + widget.deliveryFee + widget.tax;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 128.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStatusSummary(),
                          SizedBox(height: 24.h),
                          _buildVoiceSection(),
                          SizedBox(height: 24.h),
                          _buildAiInsight(),
                          SizedBox(height: 24.h),
                          _buildOrderBreakdown(),
                          SizedBox(height: 24.h),
                          _buildPaymentSummary(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildFixedActionBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
          color: const Color(0xFFF8FAFC).withValues(alpha: 0.85),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIconButton(
                width: 16,
                height: 21,
                path:
                    'M2 21C1.45 21 0.979167 20.8042 0.5875 20.4125C0.195833 20.0208 0 19.55 0 19V9C0 8.45 0.195833 7.97917 0.5875 7.5875C0.979167 7.19583 1.45 7 2 7H5V9H2V19H14V9H11V7H14C14.55 7 15.0208 7.19583 15.4125 7.5875C15.8042 7.97917 16 8.45 16 9V19C16 19.55 15.8042 20.0208 15.4125 20.4125C15.0208 20.8042 14.55 21 14 21H2ZM7 15V3.825L5.4 5.425L4 4L8 0L12 4L10.6 5.425L9 3.825V15H7Z',
                onTap: () {},
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'تفاصيل الطلب',
                        style: TextStyle(
                          color: const Color(0xFF191C1E),
                          fontFamily: 'Cairo',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          height: 32 / 24,
                        ),
                      ),
                      Text(
                        widget.orderNumber,
                        style: TextStyle(
                          color: const Color(0xFF505F76),
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  _RoundIconButton(
                    width: 16,
                    height: 16,
                    path:
                        'M12.175 9H0V7H12.175L6.575 1.4L8 0L16 8L8 16L6.575 14.6L12.175 9Z',
                    color: const Color(0xFF191C1E),
                    onTap: () => Get.back(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تاريخ التوصيل',
                style: TextStyle(
                  color: const Color(0xFF505F76),
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.deliveryDate,
                style: TextStyle(
                  color: const Color(0xFF191C1E),
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  height: 24 / 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'حالة الطلب',
                style: TextStyle(
                  color: const Color(0xFF505F76),
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(9999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.statusLabel,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 21 / 14,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SvgPicture.string(
                      '<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">'
                      '<path d="M6.45 10.95L11.7375 5.6625L10.6875 4.6125L6.45 8.85L4.3125 6.7125L3.2625 7.7625L6.45 10.95ZM7.5 15C6.4625 15 5.4875 14.8031 4.575 14.4094C3.6625 14.0156 2.86875 13.4812 2.19375 12.8062C1.51875 12.1312 0.984375 11.3375 0.590625 10.425C0.196875 9.5125 0 8.5375 0 7.5C0 6.4625 0.196875 5.4875 0.590625 4.575C0.984375 3.6625 1.51875 2.86875 2.19375 2.19375C2.86875 1.51875 3.6625 0.984375 4.575 0.590625C5.4875 0.196875 6.4625 0 7.5 0C8.5375 0 9.5125 0.196875 10.425 0.590625C11.3375 0.984375 12.1312 1.51875 12.8062 2.19375C13.4812 2.86875 14.0156 3.6625 14.4094 4.575C14.8031 5.4875 15 6.4625 15 7.5C15 8.5375 14.8031 9.5125 14.4094 10.425C14.0156 11.3375 13.4812 12.1312 12.8062 12.8062C12.1312 13.4812 11.3375 14.0156 10.425 14.4094C9.5125 14.8031 8.5375 15 7.5 15Z" fill="#166534"/></svg>',
                      width: 15.w,
                      height: 15.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'الطلب الأصلي',
                style: TextStyle(
                  color: const Color(0xFF191C1E),
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 18,
                ),
              ),
              SizedBox(width: 8.w),
              SvgPicture.string(
                '<svg width="14" height="19" viewBox="0 0 14 19" fill="none" xmlns="http://www.w3.org/2000/svg">'
                '<path d="M7 12C6.16667 12 5.45833 11.7083 4.875 11.125C4.29167 10.5417 4 9.83333 4 9V3C4 2.16667 4.29167 1.45833 4.875 0.875C5.45833 0.291667 6.16667 0 7 0C7.83333 0 8.54167 0.291667 9.125 0.875C9.70833 1.45833 10 2.16667 10 3V9C10 9.83333 9.70833 10.5417 9.125 11.125C8.54167 11.7083 7.83333 12 7 12ZM6 19V15.925C4.26667 15.6917 2.83333 14.9167 1.7 13.6C0.566667 12.2833 0 10.75 0 9H2C2 10.3833 2.4875 11.5625 3.4625 12.5375C4.4375 13.5125 5.61667 14 7 14C8.38333 14 9.5625 13.5125 10.5375 12.5375C11.5125 11.5625 12 10.3833 12 9H14C14 10.75 13.4333 12.2833 12.3 13.6C11.1667 14.9167 9.73333 15.6917 8 15.925V19H6Z" fill="#2563EB"/></svg>',
                width: 14.w,
                height: 19.h,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: _isPlaying
                        ? Icon(Icons.pause, color: Colors.white, size: 18.w)
                        : Padding(
                            padding: EdgeInsets.only(left: 2.w),
                            child: SvgPicture.string(
                              '<svg width="11" height="14" viewBox="0 0 11 14" fill="none" xmlns="http://www.w3.org/2000/svg">'
                              '<path d="M0 14V0L11 7L0 14Z" fill="white"/></svg>',
                              width: 11.w,
                              height: 14.h,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Waveform(),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0:03',
                            style: TextStyle(
                              color: const Color(0xFF737686),
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              height: 18 / 12,
                            ),
                          ),
                          Text(
                            '0:12',
                            style: TextStyle(
                              color: const Color(0xFF737686),
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              height: 18 / 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE0E3E5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SvgPicture.string(
                  '<svg width="13" height="9" viewBox="0 0 13 9" fill="none" xmlns="http://www.w3.org/2000/svg">'
                  '<path d="M1.275 9L3 6C2.175 6 1.46875 5.70625 0.88125 5.11875C0.29375 4.53125 0 3.825 0 3C0 2.175 0.29375 1.46875 0.88125 0.88125C1.46875 0.29375 2.175 0 3 0C3.825 0 4.53125 0.29375 5.11875 0.88125C5.70625 1.46875 6 2.175 6 3C6 3.2875 5.96562 3.55312 5.89687 3.79688C5.82812 4.04063 5.725 4.275 5.5875 4.5L3 9H1.275ZM8.025 9L9.75 6C8.925 6 8.21875 5.70625 7.63125 5.11875C7.04375 4.53125 6.75 3.825 6.75 3C6.75 2.175 7.04375 1.46875 7.63125 0.88125C8.21875 0.29375 8.925 0 9.75 0C10.575 0 11.2812 0.29375 11.8687 0.88125C12.4562 1.46875 12.75 2.175 12.75 3C12.75 3.2875 12.7156 3.55312 12.6469 3.79688C12.5781 4.04063 12.475 4.275 12.3375 4.5L9.75 9H8.025Z" fill="#737686"/></svg>',
                  width: 13.w,
                  height: 9.h,
                ),
                SizedBox(height: 4.h),
                Text(
                  '"${widget.transcript}"',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: const Color(0xFF434655),
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsight() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'رؤية الذكاء الاصطناعي',
                style: TextStyle(
                  color: const Color(0xFF2563EB),
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 18,
                ),
              ),
              SizedBox(width: 8.w),
              SvgPicture.string(
                '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">'
                '<path d="M18 8L16.75 5.25L14 4L16.75 2.75L18 0L19.25 2.75L22 4L19.25 5.25L18 8ZM18 22L16.75 19.25L14 18L16.75 16.75L18 14L19.25 16.75L22 18L19.25 19.25L18 22ZM8 19L5.5 13.5L0 11L5.5 8.5L8 3L10.5 8.5L16 11L10.5 13.5L8 19Z" fill="#2563EB"/></svg>',
                width: 22.w,
                height: 22.h,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _AiStatCard(label: 'اللغة', value: 'عربي مصري'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _AiStatCard(label: 'زمن المعالجة', value: '1.2s'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _AiStatCard(
                  label: 'الثقة',
                  value: '98%',
                  valueColor: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBreakdown() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'تفاصيل المنتجات',
                style: TextStyle(
                  color: const Color(0xFF191C1E),
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 18,
                ),
              ),
              SizedBox(width: 8.w),
              SvgPicture.string(
                '<svg width="18" height="16" viewBox="0 0 18 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
                '<path d="M6 15V13H18V15H6ZM6 9V7H18V9H6ZM6 3V1H18V3H6ZM2 16C1.45 16 0.979167 15.8042 0.5875 15.4125C0.195833 15.0208 0 14.55 0 14C0 13.45 0.195833 12.9792 0.5875 12.5875C0.979167 12.1958 1.45 12 2 12C2.55 12 3.02083 12.1958 3.4125 12.5875C3.80417 12.9792 4 13.45 4 14C4 14.55 3.80417 15.0208 3.4125 15.4125C3.02083 15.8042 2.55 16 2 16ZM2 10C1.45 10 0.979167 9.80417 0.5875 9.4125C0.195833 9.02083 0 8.55 0 8C0 7.45 0.195833 6.97917 0.5875 6.5875C0.979167 6.19583 1.45 6 2 6C2.55 6 3.02083 6.19583 3.4125 6.5875C3.80417 6.97917 4 7.45 4 8C4 8.55 3.80417 9.02083 3.4125 9.4125C3.02083 9.80417 2.55 10 2 10ZM2 4C1.45 4 0.979167 3.80417 0.5875 3.4125C0.195833 3.02083 0 2.55 0 2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0C2.55 0 3.02083 0.195833 3.4125 0.5875C3.80417 0.979167 4 1.45 4 2C4 2.55 3.80417 3.02083 3.4125 3.4125C3.02083 3.80417 2.55 4 2 4Z" fill="#2563EB"/></svg>',
                width: 18.w,
                height: 16.h,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final product in widget.products) ...[
                _ProductItemCard(product: product),
                SizedBox(height: 12.h),
              ],
            ],
          ),
          InkWell(
            onTap: () => setState(() => _showWhySelected = !_showWhySelected),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedRotation(
                    turns: _showWhySelected ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.string(
                      '<svg width="12" height="8" viewBox="0 0 12 8" fill="none" xmlns="http://www.w3.org/2000/svg">'
                      '<path d="M6 7.4L0 1.4L1.4 0L6 4.6L10.6 0L12 1.4L6 7.4Z" fill="#2563EB"/></svg>',
                      width: 12.w,
                      height: 8.h,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'لماذا تم اختيار هذه المنتجات؟',
                    style: TextStyle(
                      color: const Color(0xFF2563EB),
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      height: 24 / 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showWhySelected)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'تم اختيار هذه المنتجات بناءً على طلبك الصوتي ومطابقتها مع مخزون الموردين المتاحين وأفضل الأسعار.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: const Color(0xFF505F76),
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 22.75 / 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'ملخص الدفع',
            style: TextStyle(
              color: const Color(0xFF191C1E),
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              height: 28 / 18,
            ),
          ),
          SizedBox(height: 16.h),
          _SummaryRow(
            label: 'المجموع الفرعي',
            value: '${widget.subtotal.toStringAsFixed(0)} EGP',
          ),
          SizedBox(height: 8.h),
          _SummaryRow(
            label: 'التوصيل',
            value: '${widget.deliveryFee.toStringAsFixed(0)} EGP',
          ),
          SizedBox(height: 8.h),
          _SummaryRow(
            label: 'الضرائب',
            value: '${widget.tax.toStringAsFixed(0)} EGP',
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 8.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0xFFE0E3E5)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_total.toStringAsFixed(0)} EGP',
                  style: TextStyle(
                    color: const Color(0xFF191C1E),
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    height: 28 / 18,
                  ),
                ),
                Text(
                  'الإجمالي',
                  style: TextStyle(
                    color: const Color(0xFF191C1E),
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    height: 28 / 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedActionBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC).withValues(alpha: 0.85),
            border: Border(top: BorderSide(color: const Color(0xFFE0E3E5))),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56.h,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7F9FB),
                        side: const BorderSide(color: Color(0xFFC3C6D7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تحميل الإيصال',
                            style: TextStyle(
                              color: const Color(0xFF191C1E),
                              fontFamily: 'Cairo',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              height: 24 / 16,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SvgPicture.string(
                            '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
                            '<path d="M8 12L3 7L4.4 5.55L7 8.15V0H9V8.15L11.6 5.55L13 7L8 12ZM2 16C1.45 16 0.979167 15.8042 0.5875 15.4125C0.195833 15.0208 0 14.55 0 14V11H2V14H14V11H16V14C16 14.55 15.8042 15.0208 15.4125 15.4125C15.0208 15.8042 14.55 16 14 16H2Z" fill="#191C1E"/></svg>',
                            width: 16.w,
                            height: 16.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: SizedBox(
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'إعادة الطلب',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              height: 24 / 16,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SvgPicture.string(
                            '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
                            '<path d="M8 16C5.76667 16 3.875 15.225 2.325 13.675C0.775 12.125 0 10.2333 0 8C0 5.76667 0.775 3.875 2.325 2.325C3.875 0.775 5.76667 0 8 0C9.15 0 10.25 0.2375 11.3 0.7125C12.35 1.1875 13.25 1.86667 14 2.75V0H16V7H9V5H13.2C12.6667 4.06667 11.9375 3.33333 11.0125 2.8C10.0875 2.26667 9.08333 2 8 2C6.33333 2 4.91667 2.58333 3.75 3.75C2.58333 4.91667 2 6.33333 2 8C2 9.66667 2.58333 11.0833 3.75 12.25C4.91667 13.4167 6.33333 14 8 14C9.28333 14 10.4417 13.6333 11.475 12.9C12.5083 12.1667 13.2333 11.2 13.65 10H15.75C15.2833 11.7667 14.3333 13.2083 12.9 14.325C11.4667 15.4417 9.83333 16 8 16Z" fill="white"/></svg>',
                            width: 16.w,
                            height: 16.h,
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
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final double width;
  final double height;
  final String path;
  final Color color;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.width,
    required this.height,
    required this.path,
    this.color = const Color(0xFF191C1E),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 14.h),
        child: SvgPicture.string(
          '<svg width="$width" height="$height" viewBox="0 0 $width $height" fill="none" xmlns="http://www.w3.org/2000/svg">'
          '<path d="$path" fill="${_hex(color)}"/></svg>',
          width: width.w,
          height: height.h,
        ),
      ),
    );
  }

  String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

class _Waveform extends StatelessWidget {
  const _Waveform();

  static const List<double> _heights = [
    12, 24, 16, 32, 20, 8, 20, 12, 8, 16, 28, 8, 12, 20, 8,
  ];
  static const int _activeFrom = 10;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_heights.length, (i) {
          final isActive = i >= _activeFrom;
          return Container(
            width: 4.w,
            height: _heights[i].h,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2.r),
            ),
          );
        }),
      ),
    );
  }
}

class _AiStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _AiStatCard({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF191C1E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF505F76),
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              height: 24 / 12,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              height: 24 / 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItemCard extends StatelessWidget {
  final VoiceOrderProduct product;

  const _ProductItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E3E5)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  color: const Color(0xFF191C1E),
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  height: 24 / 16,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEEF0),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  product.supplier,
                  style: TextStyle(
                    color: const Color(0xFF505F76),
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    height: 18 / 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    product.requestedQuantity,
                    style: TextStyle(
                      color: const Color(0xFF191C1E),
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                    ),
                  ),
                  Text(
                    ' :المطلوب',
                    style: TextStyle(
                      color: const Color(0xFF505F76),
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    product.detectedQuantity,
                    style: TextStyle(
                      color: const Color(0xFF2563EB),
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                  ),
                  Text(
                    ' :المُكتشف',
                    style: TextStyle(
                      color: const Color(0xFF505F76),
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF505F76),
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF505F76),
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
