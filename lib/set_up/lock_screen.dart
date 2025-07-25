import 'package:flutter/material.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const LockScreen({super.key, required this.onSuccess});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  List<String> pin = [];
  List<String> firstPin = [];
  bool isConfirming = false;
  String errorMessage = '';

  void onNumberPress(String number) {
    if (pin.length < 4) {
      setState(() {
        pin.add(number);
        errorMessage = '';
      });

      if (pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!isConfirming) {
            setState(() {
              firstPin = List.from(pin);
              pin.clear();
              isConfirming = true;
            });
          } else {
            if (_pinsMatch()) {
              widget.onSuccess(); // Go to home
            } else {
              setState(() {
                pin.clear();
                firstPin.clear();
                isConfirming = false;
                errorMessage = 'PINs did not match. Try again.';
              });
            }
          }
        });
      }
    }
  }

  bool _pinsMatch() {
    for (int i = 0; i < 4; i++) {
      if (pin[i] != firstPin[i]) return false;
    }
    return true;
  }

  void onBackspace() {
    if (pin.isNotEmpty) {
      setState(() {
        pin.removeLast();
      });
    }
  }

  Widget buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
            (index) => Container(
          margin: const EdgeInsets.all(8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: index < pin.length ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget buildKey(String text) {
    return GestureDetector(
      onTap: () => onNumberPress(text),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B61FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              isConfirming ? "Re-type your PIN" : "Let's set up your PIN",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            buildPinDots(),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFEEE7FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...List.generate(9, (index) => buildKey('${index + 1}')),
                      const SizedBox.shrink(),
                      buildKey('0'),
                      GestureDetector(
                        onTap: onBackspace,
                        child: const Icon(Icons.backspace_outlined, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
