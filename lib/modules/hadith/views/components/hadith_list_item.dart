import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/global/widget/global_text.dart';
import '/utils/styles/k_colors.dart';
import '../../model/hadith_model.dart';

class HadithListItem extends StatelessWidget {
  final HadithModel hadith;
  final VoidCallback onTap;

  const HadithListItem({super.key, required this.hadith, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: KColor.fill.color,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: KColor.primary.color,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: GlobalText(
                    str: "Hadith #${hadith.hadithNumber}",
                    fontSize: 12,
                    color: KColor.white.color,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: GlobalText(
                    str: "Book #${hadith.bookNumber}",
                    fontSize: 12,
                    color: KColor.grey.color,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            GlobalText(
              str: hadith.narrator,
              fontSize: 14,
              color: KColor.secondary.color,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 4.h),
            GlobalText(
              str:
                  hadith.text.length > 100
                      ? "${hadith.text.substring(0, 100)}..."
                      : hadith.text,
              fontSize: 14,
              color: KColor.black.color,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            GlobalText(
              str: hadith.reference,
              fontSize: 12,
              color: KColor.grey.color,
            ),
          ],
        ),
      ),
    );
  }
}
