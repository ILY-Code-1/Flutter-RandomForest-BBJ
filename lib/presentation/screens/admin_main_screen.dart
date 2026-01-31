// File: admin_main_screen.dart
// Main screen untuk admin (Home, Riwayat, dan FAB untuk tambah prediksi)

import 'package:flutter/material.dart';
import 'package:flutter_randomdforest_bbj/presentation/screens/users_screen.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/prediction_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'dashboard_screen.dart';
import 'riwayat_prediksi_screen.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    final predictionController = Get.find<PredictionController>();

    final List<Widget> screens = [
      const DashboardScreen(),
      const RiwayatPrediksiScreen(),
      const UsersScreen(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navigationController.currentIndex.value,
          children: screens,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          predictionController.clearForm();
          Get.toNamed(AppRoutes.pilihanInput);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                label: 'Beranda',
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
              _buildNavItem(
                icon: Icons.people_alt_outlined,
                label: 'Kelola User',
                isSelected: navigationController.currentIndex.value == 2,
                onTap: () => navigationController.changePage(2),
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
