// File: marketing_main_screen.dart
// Main screen untuk marketing (hanya Home dan Riwayat)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/prediction_controller.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'riwayat_prediksi_screen.dart';

class MarketingMainScreen extends StatelessWidget {
  const MarketingMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    final List<Widget> screens = [
      const DashboardScreen(),
      const RiwayatPrediksiScreen(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: navigationController.currentIndex.value,
            children: screens,
          )),
      bottomNavigationBar: Obx(() => _buildBottomNavBar(navigationController)),
    );
  }

  Widget _buildBottomNavBar(NavigationController navigationController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home Button
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: navigationController.currentIndex.value == 0,
                onTap: () => navigationController.changePage(0),
              ),
              // History Button
              _buildNavItem(
                icon: Icons.access_time,
                label: 'Riwayat',
                isSelected: navigationController.currentIndex.value == 1,
                onTap: () => navigationController.changePage(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
