// File: dashboard_screen.dart
// Deskripsi: Screen Dashboard/Home yang menampilkan info Random Forest,
// statistik hasil prediksi, dan cara kerja Random Forest.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/prediction_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/nasabah_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PredictionController>();
    final authController = Get.find<AuthController>();
    final nasabahController = Get.find<NasabahController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "BPR BOGOR JABAR\nRANDOM FOREST APP",
        showLogo: true,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, authController),
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRandomForestInfo(),
                  const SizedBox(height: 16),
                  _buildDataNasabah(nasabahController),
                  const SizedBox(height: 16),
                  _buildHasilPrediksi(controller),
                  const SizedBox(height: 16),
                  _buildCaraKerja(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRandomForestInfo() {
    return InfoCard(
      title: 'APA ITU RANDOM FOREST?',
      description:
          'Random Forest adalah algoritma machine learning yang menggunakan banyak pohon keputusan (decision tree) untuk membuat prediksi. Setiap pohon memberikan "suara" dan hasil akhir ditentukan berdasarkan suara terbanyak (voting). Metode ini sangat efektif untuk klasifikasi dan prediksi karena menggabungkan kekuatan banyak model.',
      illustration: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.park, size: 50, color: AppColors.secondary),
            Positioned(
              right: 5,
              bottom: 5,
              child: Icon(
                Icons.park,
                size: 30,
                color: AppColors.secondary.withValues(alpha: 0.6),
              ),
            ),
            Positioned(
              left: 5,
              bottom: 10,
              child: Icon(
                Icons.park,
                size: 25,
                color: AppColors.secondary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataNasabah(NasabahController nasabahController) {
    return Obx(
      () => GreenInfoCard(
        title: 'Data Nasabah BBJ',
        child: Row(
          children: [
            Expanded(
              child: YellowStatBox(
                icon: Icons.person,
                label: 'Nasabah Aktif',
                value: nasabahController.jumlahAktif.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: YellowStatBox(
                icon: Icons.person_off,
                label: 'Nasabah Pasif',
                value: nasabahController.jumlahPasif.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: YellowStatBox(
                icon: Icons.people,
                label: 'Total Nasabah',
                value: nasabahController.nasabahList.length.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHasilPrediksi(PredictionController controller) {
    return Obx(() {
      final latest = controller.latestSession;
      final canNavigate = latest != null;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canNavigate
              ? () {
                  controller.setCurrentSession(latest);
                  Get.toNamed(AppRoutes.detail);
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: GreenInfoCard(
            title: 'Hasil Prediksi Terbaru',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (latest == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Belum ada riwayat prediksi',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.touch_app,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Ketuk untuk lihat detail',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          latest.flag,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: YellowStatBox(
                          icon: Icons.person,
                          label: 'Nasabah Aktif',
                          value: latest.nasabahAktif.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: YellowStatBox(
                          icon: Icons.person_off,
                          label: 'Nasabah Pasif',
                          value: latest.nasabahTidakAktif.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCaraKerja() {
    return GreenInfoCard(
      title: 'Cara Kerja Random Forest',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCaraKerjaItem(
            '1',
            'Data Training',
            'Dataset nasabah digunakan untuk melatih multiple decision trees dengan sampling acak.',
          ),
          const SizedBox(height: 12),
          _buildCaraKerjaItem(
            '2',
            'Prediksi Pohon',
            'Setiap pohon keputusan membuat prediksi independen berdasarkan fitur nasabah.',
          ),
          const SizedBox(height: 12),
          _buildCaraKerjaItem(
            '3',
            'Voting Majority',
            'Hasil akhir ditentukan berdasarkan suara terbanyak dari semua pohon keputusan.',
          ),
        ],
      ),
    );
  }

  Widget _buildCaraKerjaItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await authController.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
