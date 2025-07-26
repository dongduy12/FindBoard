import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //FlutterLogo(size: isSmallScreen ? 100 : 200),
        Image.asset(
          'assets/logo/logo.png', // Đường dẫn đến logo của bạn
          width: isSmallScreen ? 100 : 200, // Kích thước tương ứng với màn hình
          height: isSmallScreen ? 100 : 200,
          fit: BoxFit.contain, // Đảm bảo logo không bị méo
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome to PESystem!",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}