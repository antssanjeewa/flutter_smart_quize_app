import 'package:flutter/material.dart';
import 'package:quize_app/utils/theme.dart';
import 'package:quize_app/views/user_selection_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: AppTheme.theme,
      home: UserSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
