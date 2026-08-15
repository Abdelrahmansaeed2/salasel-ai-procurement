import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/status_mapper.dart';
import '../controllers/home_controller.dart';
import '../theme/home_colors.dart';

class RecentOrderTile extends StatelessWidget {
  final RecentOrder order;
  final bool showDivider;
  final VoidCallback? onTap;

  const RecentOrderTile({
    super.key,
    required this.order,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusBg =
        order.isDelivered ? HomeColors.statusDeliveredBg : HomeColors.statusConfirmedBg;
    final statusColor =
        order.isDelivered ? HomeColors.statusDeliveredText : HomeColors.statusConfirmedText;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: HomeColors.divider, width: 1.w))
              : null,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    StatusMapper.translate(order.status),
                    style: TextStyle(
                      color: statusColor,
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.5.h,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  order.time,
                  style: TextStyle(
                    color: HomeColors.orderSubtitle,
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.5.h,
                  ),
                ),
              ],
            ),
            Spacer(),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.supplier,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: HomeColors.orderTitle,
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.5.h,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    order.items,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: HomeColors.orderSubtitle,
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5.h,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 40.w,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HomeColors.orderIconBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(order.emoji, style: TextStyle(fontSize: 18.sp)),
            ),
          ],
        ),
      ),
    );
  }
}
