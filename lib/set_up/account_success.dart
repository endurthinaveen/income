import 'package:flutter/material.dart';

class AccountSuccessScreen extends StatefulWidget {
  final VoidCallback onNext;

  const AccountSuccessScreen({super.key, required this.onNext});

  @override
  State<AccountSuccessScreen> createState() => _AccountSuccessScreenState();
}

class _AccountSuccessScreenState extends State<AccountSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF7B61FF),
      body: Center(
        child: Icon(Icons.check_circle_outline, color: Colors.white, size: 100),
      ),
    );
  }
}
