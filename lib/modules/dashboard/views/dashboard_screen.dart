import '/global/widget/global_appbar.dart';
import '/global/widget/global_text.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Dashboard",
      ),
      body: const Center(
        child: GlobalText(str: "Project Setup"),
      ),
    );
  }
}

