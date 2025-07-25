import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expenses_tracker/pages/slash_screen.dart';
import 'package:personal_expenses_tracker/set_up/account_success.dart';
import 'package:personal_expenses_tracker/set_up/add_account.dart';
import 'package:personal_expenses_tracker/set_up/lets_go.dart';
import 'package:personal_expenses_tracker/set_up/lock_screen.dart';
import 'bloc/transaction_bloc.dart';
import 'dark_mood/dark_mood.dart';
import 'pages/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  bool _showLock = false;
  bool _showAccountSetup = false;
  bool _showAddAccount = false;
  bool _showSuccess = false;
  bool _showHome = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSplash = false;
        _showLock = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionBloc(),
      child: Builder(
        builder: (context) {
          final themeNotifier = Provider.of<ThemeNotifier>(context);

          Widget currentScreen;

          if (_showSplash) {
            currentScreen = const SplashScreen();
          } else if (_showLock) {
            currentScreen = LockScreen(onSuccess: () {
              setState(() {
                _showLock = false;
                _showAccountSetup = true;
              });
            });
          } else if (_showAccountSetup) {
            currentScreen = AccountSetupScreen(onNext: () {
              setState(() {
                _showAccountSetup = false;
                _showAddAccount = true;
              });
            });
          } else if (_showAddAccount) {
            currentScreen = AddAccountScreen(onNext: () {
              setState(() {
                _showAddAccount = false;
                _showSuccess = true;
              });
            });
          } else if (_showSuccess) {
            currentScreen = AccountSuccessScreen(onNext: () {
              setState(() {
                _showSuccess = false;
                _showHome = true;
              });
            });
          } else {
            currentScreen = const HomePage();
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Personal Expenses Tracker',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeNotifier.currentTheme,
            home: currentScreen,
          );
        },
      ),
    );
  }
}
