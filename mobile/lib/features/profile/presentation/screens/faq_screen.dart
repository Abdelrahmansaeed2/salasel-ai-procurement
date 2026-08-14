import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/knowledge_base_controller.dart';

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

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final KnowledgeBaseController _controller = Get.put(KnowledgeBaseController());

  @override
  void initState() {
    super.initState();
    _controller.fetchFaqs();
  }

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
            'الأسئلة الشائعة',
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
        body: Obx(() {
          if (_controller.isLoadingFaqs.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.faqs.isEmpty) {
            return Center(
              child: Text(
                'لا توجد أسئلة شائعة حالياً.',
                style: TextStyle(
                  color: const Color(0xFF191C1E),
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: _controller.faqs.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final faq = _controller.faqs[index];
              return Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq.title,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      faq.content,
                      style: TextStyle(
                        color: const Color(0xFF54647A),
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
