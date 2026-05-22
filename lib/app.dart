import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/main_scaffold.dart';

class CondoKeyApp extends StatelessWidget {
  const CondoKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CondoKey',
      theme: AppTheme.darkTheme,
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}
