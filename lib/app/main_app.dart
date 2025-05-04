import 'package:flutter/material.dart';
import 'package:quize_app/utils/theme.dart';
import 'package:quize_app/views/home_page.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: AppTheme.theme,
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
