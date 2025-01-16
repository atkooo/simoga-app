import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BuildNoInternet extends StatelessWidget {
  const BuildNoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Lottie.asset(
                'assets/lottie/no-internet.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
