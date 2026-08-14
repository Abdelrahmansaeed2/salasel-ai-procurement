import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

Widget _pathIcon(
  String path, {
  required double vbW,
  required double vbH,
  required double w,
  required double h,
  required Color color,
}) {
  return SvgPicture.string(
    '<svg width="$vbW" height="$vbH" viewBox="0 0 $vbW $vbH" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="$path" fill="#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}"/></svg>',
    width: w,
    height: h,
  );
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: AppBar(
          toolbarHeight: 64.h,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleSpacing: 0,
          leadingWidth: 40.w,
          leading: Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 40.w,
                height: 40.h,
                child: Center(
                  child: _pathIcon(
                    'M1.775 20L0 18.225L8.225 10L0 1.775L1.775 0L11.775 10L1.775 20Z',
                    vbW: 12,
                    vbH: 20,
                    w: 12.w,
                    h: 20.h,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            'محادثة الدعم',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'نافذة المحادثة ستعرض هنا...',
                style: TextStyle(
                  color: const Color(0xFF191C1E),
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
