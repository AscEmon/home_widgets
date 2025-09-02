import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/global/widget/global_appbar.dart';
import '/global/widget/global_text.dart';
import '/utils/app_routes.dart';
import '/utils/enum.dart';
import '/utils/navigation.dart';
import '/utils/styles/k_colors.dart';
import '../bloc/hadith_bloc.dart';
import '../bloc/hadith_event.dart';
import '../bloc/hadith_state.dart';
import 'components/hadith_list_item.dart';

class HadithListScreen extends StatefulWidget {
  const HadithListScreen({super.key});

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHadithList();
    _setupScrollListener();
  }

  void _loadHadithList() {
    context.read<HadithBloc>().add(const FetchHadithList());
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<HadithBloc>().add(const FetchMoreHadithList());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColor.white.color,
      appBar: GlobalAppBar(
        title: "Bukhari Hadith",
        actions: [
          IconButton(
            onPressed: () {
              context.read<HadithBloc>().add(const FetchDailyHadith());
              _showDailyHadithBottomSheet(context);
            },
            icon: Icon(
              Icons.today,
              color: KColor.white.color,
            ),
          ),
        ],
      ),
      body: BlocBuilder<HadithBloc, HadithState>(
        buildWhen: (previous, current) => 
          previous.hadithListStatus != current.hadithListStatus ||
          previous.hadithList != current.hadithList,
        builder: (context, state) {
          if (state.hadithListStatus == AppStatus.loading && state.hadithList.isEmpty) {
            return _buildLoadingView();
          } else if (state.hadithListStatus == AppStatus.error && state.hadithList.isEmpty) {
            return _buildErrorView(state.errorMessage);
          } else {
            return _buildHadithListView(state);
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        color: KColor.primary.color,
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlobalText(
            str: "Failed to load hadith list",
            fontSize: 16,
            color: KColor.red.color,
          ),
          SizedBox(height: 8.h),
          GlobalText(
            str: errorMessage,
            fontSize: 14,
            color: KColor.grey.color,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadHadithList,
            style: ElevatedButton.styleFrom(
              backgroundColor: KColor.primary.color,
              foregroundColor: KColor.white.color,
            ),
            child: const GlobalText(
              str: "Retry",
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithListView(HadithState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HadithBloc>().add(const FetchHadithList(isRefresh: true));
      },
      color: KColor.primary.color,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: state.hadithList.length + (state.hasMoreData ? 1 : 0),
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index < state.hadithList.length) {
            final hadith = state.hadithList[index];
            return HadithListItem(
              hadith: hadith,
              onTap: () {
                Navigation.push(
                  context,
                  appRoutes: AppRoutes.hadithDetail,
                  arguments: hadith.id,
                );
              },
            );
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: CircularProgressIndicator(
                  color: KColor.primary.color,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showDailyHadithBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: KColor.white.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: KColor.grey.color,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              GlobalText(
                str: "Daily Hadith",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: KColor.primary.color,
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: BlocBuilder<HadithBloc, HadithState>(
                  buildWhen: (previous, current) => 
                    previous.dailyHadithStatus != current.dailyHadithStatus ||
                    previous.dailyHadith != current.dailyHadith,
                  builder: (context, state) {
                    if (state.dailyHadithStatus == AppStatus.loading) {
                      return _buildLoadingView();
                    } else if (state.dailyHadithStatus == AppStatus.error) {
                      return _buildErrorView(state.errorMessage);
                    } else if (state.dailyHadith != null) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlobalText(
                              str: state.dailyHadith!.narrator,
                              fontSize: 14,
                              color: KColor.grey.color,
                            ),
                            SizedBox(height: 8.h),
                            GlobalText(
                              str: state.dailyHadith!.text,
                              fontSize: 16,
                              color: KColor.black.color,
                            ),
                            SizedBox(height: 8.h),
                            GlobalText(
                              str: state.dailyHadith!.reference,
                              fontSize: 12,
                              color: KColor.grey.color,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: GlobalText(
                          str: "No daily hadith available",
                          fontSize: 16,
                          color: KColor.grey.color,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
