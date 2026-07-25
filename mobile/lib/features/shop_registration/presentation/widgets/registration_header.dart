import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';

class RegistrationHeader extends StatelessWidget implements PreferredSizeWidget {
  const RegistrationHeader({
    super.key,
    required this.title,
    this.titleWeight = FontWeight.w500,
    this.backgroundColor = Colors.white,
    this.onBack,
  });

  final String title;
  final FontWeight titleWeight;
  final Color backgroundColor;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const FigmaIcon(ShopRegIcons.help, color: ShopRegColors.primary, size: 20),
              ),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: titleWeight,
                      color: ShopRegColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    icon: const FigmaIcon(ShopRegIcons.headerChevron, color: ShopRegColors.primary, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
