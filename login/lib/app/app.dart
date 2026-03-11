import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

class PeerAssessmentApp extends StatelessWidget {
  const PeerAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peer Assessment',
      theme: AppTheme.themeData,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
