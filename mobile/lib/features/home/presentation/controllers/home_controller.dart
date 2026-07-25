import 'package:get/get.dart';

class QuickStat {
  final String label;
  final String value;
  const QuickStat({required this.label, required this.value});
}

class RecentOrder {
  final String emoji;
  final String supplier;
  final String items;
  final String status;
  final bool isDelivered;
  final String time;
  const RecentOrder({
    required this.emoji,
    required this.supplier,
    required this.items,
    required this.status,
    required this.isDelivered,
    required this.time,
  });
}

class HomeController extends GetxController {
  final RxInt bottomNavIndex = 0.obs;

  final List<QuickStat> quickStats = const [
    QuickStat(label: 'تنبيه نقص المخزون', value: '12'),
    QuickStat(label: 'طلبات قيد التوصيل', value: '5'),
    QuickStat(label: 'بانتظار الاعتماد', value: '8'),
  ];

  final List<RecentOrder> recentOrders = const [
    RecentOrder(
      emoji: '🧺',
      supplier: 'الجوهرة للتوزيع',
      items: 'مياه × ٢٠، عصير × ١٢',
      status: 'مؤكد',
      isDelivered: false,
      time: 'منذ ٨ دقائق',
    ),
    RecentOrder(
      emoji: '🧺',
      supplier: 'النخيل للمواد الغذائية',
      items: 'أرز × ٥، سكر × ٣',
      status: 'تم التوصيل',
      isDelivered: true,
      time: 'منذ ٤٢ دقيقة',
    ),
  ];

  void changeTab(int index) {
    bottomNavIndex.value = index;
  }
}
