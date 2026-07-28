import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _NavItemData {
  final String svgPath;
  final String label;
  final int? badgeCount;

  const _NavItemData({
    required this.svgPath,
    required this.label,
    this.badgeCount,
  });
}

const List<_NavItemData> _navItems = [
  _NavItemData(
    label: 'الرئيسية',
    svgPath:
        'M13.75 19.25V11.9167C13.75 11.6736 13.6534 11.4404 13.4815 11.2685C13.3096 11.0966 13.0764 11 12.8333 11H9.16667C8.92355 11 8.69039 11.0966 8.51849 11.2685C8.34658 11.4404 8.25 11.6736 8.25 11.9167V19.25M2.75 9.16684C2.74994 8.90015 2.80806 8.63666 2.92031 8.39475C3.03255 8.15283 3.19623 7.93832 3.39992 7.76617L9.81658 2.26709C10.1475 1.98742 10.5667 1.83398 11 1.83398C11.4333 1.83398 11.8525 1.98742 12.1834 2.26709L18.6001 7.76617C18.8038 7.93832 18.9674 8.15283 19.0797 8.39475C19.1919 8.63666 19.2501 8.90015 19.25 9.16684V17.4168C19.25 17.9031 19.0568 18.3694 18.713 18.7132C18.3692 19.057 17.9029 19.2502 17.4167 19.2502H4.58333C4.0971 19.2502 3.63079 19.057 3.28697 18.7132C2.94315 18.3694 2.75 17.9031 2.75 17.4168V9.16684Z',
  ),
  _NavItemData(
    label: 'المخزون',
    badgeCount: 7,
    svgPath:
        'M10.0833 19.9194C10.362 20.0803 10.6782 20.165 11 20.165C11.3218 20.165 11.638 20.0803 11.9167 19.9194L18.3333 16.2527C18.6118 16.092 18.843 15.8608 19.0039 15.5825C19.1648 15.3042 19.2497 14.9884 19.25 14.6669V7.33357C19.2497 7.01207 19.1648 6.69631 19.0039 6.41797C18.843 6.13962 18.6118 5.90849 18.3333 5.74774L11.9167 2.08107C11.638 1.92016 11.3218 1.83545 11 1.83545C10.6782 1.83545 10.362 1.92016 10.0833 2.08107L3.66667 5.74774C3.38824 5.90849 3.15698 6.13962 2.99609 6.41797C2.8352 6.69631 2.75033 7.01207 2.75 7.33357V14.6669C2.75033 14.9884 2.8352 15.3042 2.99609 15.5825C3.15698 15.8608 3.38824 16.092 3.66667 16.2527L10.0833 19.9194Z M11 20.1667V11 M3.01581 6.4165L11 10.9998L18.9841 6.4165 M6.875 3.91406L15.125 8.6349',
  ),
  _NavItemData(
    label: 'الطلبات',
    badgeCount: 4,
    svgPath:
        'M13.75 1.8335H8.25001C7.74375 1.8335 7.33334 2.2439 7.33334 2.75016V4.5835C7.33334 5.08976 7.74375 5.50016 8.25001 5.50016H13.75C14.2563 5.50016 14.6667 5.08976 14.6667 4.5835V2.75016C14.6667 2.2439 14.2563 1.8335 13.75 1.8335Z M14.6667 3.6665H16.5C16.9862 3.6665 17.4525 3.85966 17.7964 4.20347C18.1402 4.54729 18.3333 5.01361 18.3333 5.49984V18.3332C18.3333 18.8194 18.1402 19.2857 17.7964 19.6295C17.4525 19.9733 16.9862 20.1665 16.5 20.1665H5.49999C5.01376 20.1665 4.54744 19.9733 4.20363 19.6295C3.85981 19.2857 3.66666 18.8194 3.66666 18.3332V5.49984C3.66666 5.01361 3.85981 4.54729 4.20363 4.20347C4.54744 3.85966 5.01376 3.6665 5.49999 3.6665H7.33332 M11 10.0835H14.6667 M11 14.6665H14.6667 M7.33334 10.0835H7.34334 M7.33334 14.6665H7.34334',
  ),
  _NavItemData(
    label: 'حسابي',
    svgPath:
        'M17.4167 19.25V17.4167C17.4167 16.4442 17.0304 15.5116 16.3427 14.8239C15.6551 14.1363 14.7225 13.75 13.75 13.75H8.25001C7.27755 13.75 6.34492 14.1363 5.65729 14.8239C4.96965 15.5116 4.58334 16.4442 4.58334 17.4167V19.25M11 10.0833C13.0251 10.0833 14.6667 8.44171 14.6667 6.41667C14.6667 4.39162 13.0251 2.75 11 2.75C8.97497 2.75 7.33334 4.39162 7.33334 6.41667C7.33334 8.44171 8.97497 10.0833 11 10.0833Z',
  ),
];

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const Color _activeColor = Color(0xFF2563EB);
  static const Color _inactiveColor = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.w)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = index == currentIndex;
              final color = isActive ? _activeColor : _inactiveColor;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(index),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isActive ? 1.1 : 1,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: SizedBox(
                            width: 22.w,
                            height: 22.h,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SvgPicture.string(
                                  '<svg width="22" height="22" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">'
                                  '<path d="${item.svgPath}" stroke="${_hex(color)}" stroke-width="1.83333" stroke-linecap="round" stroke-linejoin="round"/>'
                                  '</svg>',
                                ),
                                if (item.badgeCount != null)
                                  Positioned(
                                    left: 12.w,
                                    top: -6,
                                    child: Container(
                                      width: 16.w,
                                      height: 16.h,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${item.badgeCount}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w700,
                                          height: 1.5.h,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 200),
                          style: TextStyle(
                            color: color,
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                            height: 1.5.h,
                          ),
                          child: Text(item.label),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          margin: EdgeInsets.only(top: 4.h),
                          width: isActive ? 72.w : 0,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: _activeColor,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}
