import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/features/pe_system/presentation/screens/home_page.dart';
import 'package:mobile_app/features/pe_system/presentation/screens/settings_page.dart';
import 'package:mobile_app/features/pe_system/presentation/screens/sign_in_page.dart';
import '../../../../core/constants/colors.dart';
import '../providers/code_provider.dart';


const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.bookmark_border_outlined),
    activeIcon: Icon(Icons.bookmark_rounded),
    label: 'Detail',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings_outlined),
    activeIcon: Icon(Icons.settings_rounded),
    label: 'Settings',
  ),
];

class NavigationRailPage extends StatefulWidget {
  const NavigationRailPage({super.key});

  @override
  _NavigationRailPageState createState() => _NavigationRailPageState();
}

class _NavigationRailPageState extends State<NavigationRailPage> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    //   print('NavigationRailPage: Setting SystemUIOverlayStyle, isDarkMode: $isDarkMode');
    //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarColor: isDarkMode ? Colors.grey[900] : AppColors.background,
    //     statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    //     systemNavigationBarColor: isDarkMode ? Colors.grey[900] : AppColors.background,
    //     systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    //   ));
    // });
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CodeProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 800;
    final bool isLargeScreen = width > 800;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
        items: _navBarItems,
        currentIndex: provider.selectedIndex,
        onTap: (int index) {
          provider.setSelectedIndex(index);
        },
      )
          : null,
      body: Row(
        children: <Widget>[
          if (!isSmallScreen)
            NavigationRail(
              selectedIndex: provider.selectedIndex,
              onDestinationSelected: (int index) {
                provider.setSelectedIndex(index);
              },
              extended: isLargeScreen,
              destinations: const[
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_border_outlined),
                  selectedIcon: Icon(Icons.bookmark_rounded),
                  label: Text('Detail'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
          //const VerticalDivider(),
          Expanded(
            child: IndexedStack(
              index: provider.selectedIndex,
              children: const [
                HomePage(),
                Center(child: Text('Bookmarks Page')),
                SettingsPage(),
              ],
            ),

              // Expanded( Khong giu lai status khi chuyển page
              //   child: provider.selectedIndex == 0
              //       ? const HomeScreen()
              //       : provider.selectedIndex == 1
              //       ? const Center(child: Text('Bookmarks Page'))
              //       : const Center(child: Text('Profile Page')),
              // )
              //
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    final codeProvider = Provider.of<CodeProvider>(context, listen: false);
    codeProvider.logout();

    // Xóa toàn bộ navigation stack và đưa về login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInPage()),
          (Route<dynamic> route) => false,
    );
  }
}