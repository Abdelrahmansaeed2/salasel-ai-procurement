import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiInsightsCard extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  const AiInsightsCard({
    super.key,
    required this.onAdd,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'توقعات الذكاء الاصطناعي',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: const Color(0xFF475569),
                          fontSize: 14.sp,
                          height: 1.6,
                          fontFamily: 'Cairo',
                        ),
                        children: const [
                          TextSpan(text: 'بناءً على مبيعات الأسبوع الماضي، من\nالمتوقع نفاذ منتج '),
                          TextSpan(
                            text: 'سكر الأسرة',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' خلال يومين.\nهل ترغب في إضافته لقائمة الطلبات؟'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFF2563EB),
                  size: 28.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              TextButton(
                onPressed: onAdd,
                child: Text(
                  'أضف الآن',
                  style: TextStyle(
                    color: const Color(0xFF2563EB),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'تجاهل التنبيه',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
