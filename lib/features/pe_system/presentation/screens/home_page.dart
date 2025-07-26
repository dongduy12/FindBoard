import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/colors.dart';
import 'package:mobile_app/features/pe_system/presentation/screens/retest_screen.dart';
import 'data_cloud_screen.dart';
import 'pe_system_screen.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = (width ~/ 200).clamp(2, 4);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
              children: [
                _buildFunctionCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  label:'Search List',
                  onTap:(){
                    print('Navigating to PESystemScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PESystemScreen()),
                    );
                  },
                ),
                _buildFunctionCard(
                  context,
                  icon: Icons.run_circle,
                  label: 'Retest',
                  onTap: () {
                    print('Navigating to RetestScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RetestScreen()),
                    );
                  },
                ),
                _buildFunctionCard(
                  context,
                  icon: Icons.cloud,
                  label: 'DataCloud',
                  onTap: () {
                    print('Navigating to DataCloudScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DataCloudScreen()),
                    );
                  },
                ),
              ],
          )
        ),
      ),
    );
  }

  Widget _buildFunctionCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64, // Icon lớn
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}