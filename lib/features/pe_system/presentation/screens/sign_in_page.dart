import 'package:flutter/material.dart';
import 'package:mobile_app/features/pe_system/presentation/screens/home_page.dart';
import 'package:provider/provider.dart';
import '../providers/code_provider.dart';
import '../widgets/logo.dart';
import '../widgets/form_content.dart';
import 'navigation_rail_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  void _login(BuildContext context, String email, String password) async {
    final codeProvider = Provider.of<CodeProvider>(context, listen: false);
    final success = await codeProvider.login(email, password);

    if (success && codeProvider.isLoggedIn) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NavigationRailPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CodeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: MediaQuery
                .of(context)
                .size
                .width < 600
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Logo(),
                FormContent(onLogin: _login),
              ],
            )
                : Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 800),
              child: Row(
                children: [
                  const Expanded(child: Logo()),
                  Expanded(
                    child: FormContent(onLogin: _login),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
  // Widget build(BuildContext context) {
  //   final provider = Provider.of<CodeProvider>(context);
  //
  //   // Tự động chuyển hướng nếu đã đăng nhập
  //   if (provider.isLoggedIn) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => const NavigationRailPage()),
  //             (Route<dynamic> route) => false,
  //       );
  //     });
  //   }
  //
  //   final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
  //   return Scaffold(
  //     body: SafeArea(
  //       child: Center(
  //         child: SingleChildScrollView(
  //           child: isSmallScreen
  //               ? Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               const Logo(),
  //               FormContent(onLogin: _login),
  //             ],
  //           )
  //               : Container(
  //             padding: const EdgeInsets.all(32.0),
  //             constraints: const BoxConstraints(maxWidth: 800),
  //             child: Row(
  //               children: [
  //                 const Expanded(child: Logo()),
  //                 Expanded(
  //                   child: FormContent(onLogin: _login),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );