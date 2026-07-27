import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/home_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum QuickStatVariant { pending, delivery, lowStock }

class QuickStatCard extends StatefulWidget {
  final QuickStatVariant variant;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const QuickStatCard({
    super.key,
    required this.variant,
    required this.label,
    required this.value,
    this.onTap,
  });

  static const Map<QuickStatVariant, String> _icons = {
    QuickStatVariant.pending:
        'M14 21C12.6167 21 11.4375 20.5125 10.4625 19.5375C9.4875 18.5625 9 17.3833 9 16C9 14.6167 9.4875 13.4375 10.4625 12.4625C11.4375 11.4875 12.6167 11 14 11C15.3833 11 16.5625 11.4875 17.5375 12.4625C18.5125 13.4375 19 14.6167 19 16C19 17.3833 18.5125 18.5625 17.5375 19.5375C16.5625 20.5125 15.3833 21 14 21ZM15.675 18.375L16.375 17.675L14.5 15.8V13H13.5V16.2L15.675 18.375ZM2 20C1.45 20 0.979167 19.8042 0.5875 19.4125C0.195833 19.0208 0 18.55 0 18V4C0 3.45 0.195833 2.97917 0.5875 2.5875C0.979167 2.19583 1.45 2 2 2H6.175C6.35833 1.41667 6.71667 0.9375 7.25 0.5625C7.78333 0.1875 8.36667 0 9 0C9.66667 0 10.2625 0.1875 10.7875 0.5625C11.3125 0.9375 11.6667 1.41667 11.85 2H16C16.55 2 17.0208 2.19583 17.4125 2.5875C17.8042 2.97917 18 3.45 18 4V10.25C17.7 10.0333 17.3833 9.85 17.05 9.7C16.7167 9.55 16.3667 9.41667 16 9.3V4H14V7H4V4H2V18H7.3C7.41667 18.3667 7.55 18.7167 7.7 19.05C7.85 19.3833 8.03333 19.7 8.25 20H2ZM9 4C9.28333 4 9.52083 3.90417 9.7125 3.7125C9.90417 3.52083 10 3.28333 10 3C10 2.71667 9.90417 2.47917 9.7125 2.2875C9.52083 2.09583 9.28333 2 9 2C8.71667 2 8.47917 2.09583 8.2875 2.2875C8.09583 2.47917 8 2.71667 8 3C8 3.28333 8.09583 3.52083 8.2875 3.7125C8.47917 3.90417 8.71667 4 9 4Z',
    QuickStatVariant.delivery:
        'M5 16C4.16667 16 3.45833 15.7083 2.875 15.125C2.29167 14.5417 2 13.8333 2 13H0V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H16V4H19L22 8V13H20C20 13.8333 19.7083 14.5417 19.125 15.125C18.5417 15.7083 17.8333 16 17 16C16.1667 16 15.4583 15.7083 14.875 15.125C14.2917 14.5417 14 13.8333 14 13H8C8 13.8333 7.70833 14.5417 7.125 15.125C6.54167 15.7083 5.83333 16 5 16ZM5 14C5.28333 14 5.52083 13.9042 5.7125 13.7125C5.90417 13.5208 6 13.2833 6 13C6 12.7167 5.90417 12.4792 5.7125 12.2875C5.52083 12.0958 5.28333 12 5 12C4.71667 12 4.47917 12.0958 4.2875 12.2875C4.09583 12.4792 4 12.7167 4 13C4 13.2833 4.09583 13.5208 4.2875 13.7125C4.47917 13.9042 4.71667 14 5 14ZM2 11H2.8C3.08333 10.7 3.40833 10.4583 3.775 10.275C4.14167 10.0917 4.55 10 5 10C5.45 10 5.85833 10.0917 6.225 10.275C6.59167 10.4583 6.91667 10.7 7.2 11H14V2H2V11ZM17 14C17.2833 14 17.5208 13.9042 17.7125 13.7125C17.9042 13.5208 18 13.2833 18 13C18 12.7167 17.9042 12.4792 17.7125 12.2875C17.5208 12.0958 17.2833 12 17 12C16.7167 12 16.4792 12.0958 16.2875 12.2875C16.0958 12.4792 16 12.7167 16 13C16 13.2833 16.0958 13.5208 16.2875 13.7125C16.4792 13.9042 16.7167 14 17 14ZM16 9H20.25L18 6H16V9Z',
    QuickStatVariant.lowStock:
        'M3 20C2.45 20 1.97917 19.8042 1.5875 19.4125C1.19583 19.0208 1 18.55 1 18V6.725C0.7 6.54167 0.458333 6.30417 0.275 6.0125C0.0916667 5.72083 0 5.38333 0 5V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H18C18.55 0 19.0208 0.195833 19.4125 0.5875C19.8042 0.979167 20 1.45 20 2V5C20 5.38333 19.9083 5.72083 19.725 6.0125C19.5417 6.30417 19.3 6.54167 19 6.725V18C19 18.55 18.8042 19.0208 18.4125 19.4125C18.0208 19.8042 17.55 20 17 20H3ZM3 7V18H17V7H3ZM2 5H18V2H2V5ZM7 12H13V10H7V12Z',
  };

  static const Map<QuickStatVariant, List<double>> _viewBox = {
    QuickStatVariant.pending: [19, 21],
    QuickStatVariant.delivery: [22, 16],
    QuickStatVariant.lowStock: [20, 20],
  };

  @override
  State<QuickStatCard> createState() => _QuickStatCardState();
}

class _QuickStatCardState extends State<QuickStatCard> {
  bool _pressed = false;

  Color get _border {
    switch (widget.variant) {
      case QuickStatVariant.pending:
        return HomeColors.cardPendingBorder;
      case QuickStatVariant.delivery:
        return HomeColors.cardDeliveryBorder;
      case QuickStatVariant.lowStock:
        return HomeColors.cardLowStockBorder;
    }
  }

  Color get _iconBg {
    switch (widget.variant) {
      case QuickStatVariant.pending:
        return HomeColors.cardPendingIconBg;
      case QuickStatVariant.delivery:
        return HomeColors.cardDeliveryIconBg;
      case QuickStatVariant.lowStock:
        return HomeColors.cardLowStockIconBg;
    }
  }

  Color get _iconColor {
    switch (widget.variant) {
      case QuickStatVariant.pending:
        return HomeColors.menuIcon;
      case QuickStatVariant.delivery:
        return HomeColors.cardDeliveryIcon;
      case QuickStatVariant.lowStock:
        return HomeColors.cardLowStockIcon;
    }
  }

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final vb = QuickStatCard._viewBox[widget.variant]!;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8.r),
            splashColor: _border.withValues(alpha: 0.08),
            highlightColor: _border.withValues(alpha: 0.05),
            child: Container(
              width: 160.w,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _border, width: 1.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _iconBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: SvgPicture.string(
                      '<svg width="${vb[0]}" height="${vb[1]}" viewBox="0 0 ${vb[0]} ${vb[1]}" fill="none" xmlns="http://www.w3.org/2000/svg">'
                      '<path d="${QuickStatCard._icons[widget.variant]}" fill="${_hex(_iconColor)}"/></svg>',
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.label,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: HomeColors.cardLabel,
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      height: 1.2.h,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: int.tryParse(widget.value) ?? 0),
                    duration: Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, _) {
                      final display = int.tryParse(widget.value) == null
                          ? widget.value
                          : '$animatedValue';
                      return Text(
                        display,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: HomeColors.cardValue,
                          fontFamily: 'Cairo',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.2.h,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}
