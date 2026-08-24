import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/settings_controller.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  final SettingsController settings = Get.find<SettingsController>();
  
  // Local state for the toggles (since SettingsController might not have these specific rx variables yet)
  bool _newOrders = true;
  bool _inventoryAlerts = true;
  bool _systemUpdates = true;
  bool _chatMessages = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الإشعارات',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _buildSectionTitle('إشعارات الطلبات'),
            _buildSwitchTile(
              title: 'الطلبات الجديدة',
              subtitle: 'تنبيه عند استلام طلب جديد أو تحديث حالته',
              value: _newOrders,
              onChanged: (val) => setState(() => _newOrders = val),
            ),
            SizedBox(height: 24.h),
            
            _buildSectionTitle('إشعارات المخزون'),
            _buildSwitchTile(
              title: 'تنبيهات نقص المخزون',
              subtitle: 'تنبيه عندما يقترب منتج من النفاد',
              value: _inventoryAlerts,
              onChanged: (val) => setState(() => _inventoryAlerts = val),
            ),
            SizedBox(height: 24.h),
            
            _buildSectionTitle('إشعارات عامة'),
            _buildSwitchTile(
              title: 'الرسائل والدعم',
              subtitle: 'تنبيه عند استلام رسائل من الدعم الفني',
              value: _chatMessages,
              onChanged: (val) => setState(() => _chatMessages = val),
            ),
            _buildSwitchTile(
              title: 'تحديثات النظام',
              subtitle: 'أخبار وتحديثات التطبيق والمنصة',
              value: _systemUpdates,
              onChanged: (val) => setState(() => _systemUpdates = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF004AC6),
          fontFamily: 'Cairo',
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF004AC6),
          ),
        ],
      ),
    );
  }
}
