import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: const FigmaIcon(ShopRegIcons.sparkle, color: ShopRegColors.primary, size: 22),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نصيحة سلاسل الذكية',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ShopRegColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    height: 1.6,
                    color: ShopRegColors.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
