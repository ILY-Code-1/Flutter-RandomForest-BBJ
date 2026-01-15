// File: main_screen.dart
// Deskripsi: Screen utama dengan bottom navigation bar.
// Mengelola navigasi antar tab: Home (Dashboard), Tambah Prediksi, Riwayat.
// Bottom nav memiliki ikon plus di tengah yang lebih besar dan menonjol.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/prediction_controller.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'pilihan_input_screen.dart';
import 'riwayat_prediksi_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    final predictionController = Get.find<PredictionController>();

    final List<Widget> screens = [
      const DashboardScreen(),
      const PilihanInputScreen(),
      const RiwayatPrediksiScreen(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: navigationController.currentIndex.value,
            children: screens,
          )),
      bottomNavigationBar: Obx(() => _buildBottomNavBar(
            navigationController,
            predictionController,
          )),
    );
  }

  Widget _buildBottomNavBar(
    NavigationController navigationController,
    PredictionController predictionController,
  ) {
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
              // Add Prediction Button (Prominent)
              _buildCenterButton(
                isSelected: navigationController.currentIndex.value == 1,
                onTap: () {
                  predictionController.clearForm();
                  navigationController.changePage(1);
                },
              ),
              // History Button
              _buildNavItem(
                icon: Icons.access_time,
                label: 'Riwayat',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildCenterButton({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
