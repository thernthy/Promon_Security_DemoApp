import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() => runApp(BankDemoApp(state: AppState()));

class BankDemoApp extends StatelessWidget {
  const BankDemoApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    // AppScope sits above MaterialApp so every route can reach the app state.
    return AppScope(
      notifier: state,
      child: MaterialApp(
        title: 'Demo Bank',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
