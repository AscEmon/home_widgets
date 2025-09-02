import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/utils/extension.dart';
import 'global_text.dart';

class GlobalLoader extends StatelessWidget {
  const GlobalLoader({super.key, this.text = "Loading..."});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        centerCircularProgress(),
        SizedBox(width: 10.w),
        GlobalText(str: text ?? "")
      ],
    );
  }
}


 