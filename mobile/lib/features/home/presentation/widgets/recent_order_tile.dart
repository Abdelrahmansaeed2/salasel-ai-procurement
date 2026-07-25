import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: HomeColors.divider, width: 1))
              : null,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.time,
                  style: const TextStyle(
                    color: HomeColors.orderSubtitle,
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.supplier,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: HomeColors.orderTitle,
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.items,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: HomeColors.orderSubtitle,
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HomeColors.orderIconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(order.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
