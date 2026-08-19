import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const XaneoLangStudioApp());
}

class XaneoLangStudioApp extends StatelessWidget {
  const XaneoLangStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xaneo Lang Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeView(),
    );
  }
}
