import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/global/widget/global_appbar.dart';
import '/global/widget/global_text.dart';
import '/utils/enum.dart';
import '/utils/styles/k_colors.dart';
import '../bloc/hadith_bloc.dart';
import '../bloc/hadith_event.dart';
import '../bloc/hadith_state.dart';

class HadithDetailScreen extends StatefulWidget {
  final int hadithId;

  const HadithDetailScreen({super.key, required this.hadithId});

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadHadithDetail();
  }

  void _loadHadithDetail() {
    context.read<HadithBloc>().add(
      FetchHadithDetail(hadithId: widget.hadithId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColor.white.color,
      appBar: GlobalAppBar(title: "Hadith Detail"),
      body: BlocBuilder<HadithBloc, HadithState>(
        buildWhen:
            (previous, current) =>
                previous.hadithDetailStatus != current.hadithDetailStatus ||
                previous.selectedHadith != current.selectedHadith,
        builder: (context, state) {
          if (state.hadithDetailStatus == AppStatus.loading) {
            return _buildLoadingView();
          } else if (state.hadithDetailStatus == AppStatus.error) {
            return _buildErrorView(state.errorMessage);
          } else if (state.selectedHadith != null) {
            return _buildHadithDetailView(state);
          } else {
            return _buildEmptyView();
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(color: KColor.primary.color),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlobalText(
            str: "Failed to load hadith detail",
            fontSize: 16,
            color: KColor.red.color,
          ),
          SizedBox(height: 8.h),
          GlobalText(str: errorMessage, fontSize: 14, color: KColor.grey.color),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadHadithDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: KColor.primary.color,
              foregroundColor: KColor.white.color,
            ),
            child: const GlobalText(str: "Retry", color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: GlobalText(
        str: "No hadith details available",
        fontSize: 16,
        color: KColor.grey.color,
      ),
    );
  }

  Widget _buildHadithDetailView(HadithState state) {
    final hadith = state.selectedHadith!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: KColor.primary.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: KColor.primary.color,
                    shape: BoxShape.circle,
                  ),
                  child: GlobalText(
                    str: "${hadith.hadithNumber}",
                    fontSize: 16,
                    color: KColor.white.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlobalText(
                        str: "Book #${hadith.bookNumber}",
                        fontSize: 14,
                        color: KColor.primary.color,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 4.h),
                      GlobalText(
                        str: hadith.chapter,
                        fontSize: 12,
                        color: KColor.grey.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          GlobalText(str: "Narrator", fontSize: 14, color: KColor.grey.color),
          SizedBox(height: 4.h),
          GlobalText(
            str: hadith.narrator,
            fontSize: 16,
            color: KColor.secondary.color,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 16.h),
          Divider(color: KColor.divider.color),
          SizedBox(height: 16.h),
          GlobalText(
            str: hadith.text,
            fontSize: 16,
            color: KColor.black.color,
            height: 1.5,
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: KColor.fill.color,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: KColor.divider.color),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalText(
                  str: "Reference",
                  fontSize: 14,
                  color: KColor.grey.color,
                ),
                SizedBox(height: 4.h),
                GlobalText(
                  str: hadith.reference,
                  fontSize: 14,
                  color: KColor.black.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
