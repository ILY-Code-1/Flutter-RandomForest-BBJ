// File: detail_prediksi_screen.dart
// Screen untuk menampilkan detail lengkap hasil prediksi dengan fitur download PDF

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/prediction_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/pdf_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/nasabah_detail_card.dart';

class DetailPrediksiScreen extends StatelessWidget {
  const DetailPrediksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PredictionController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'DETAIL PREDIKSI',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final session = controller.currentSession.value;

          if (session == null) {
            return const Center(
              child: Text('Data tidak ditemukan'),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailHeaderCard(
                      jumlahData: session.jumlahData,
                      akurasi: session.akurasi,
                    ),
                    const SizedBox(height: 12),
                    _buildDownloadButton(context, session),
                    const SizedBox(height: 16),
                    Text(
                      'Detail Nasabah',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 12),
                    ...session.nasabahList.map((nasabah) =>
                        NasabahDetailCard(nasabah: nasabah)),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, dynamic session) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, Color(0xFF1565C0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _downloadReport(context, session),
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
        label: const Text(
          'Download Laporan PDF',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadReport(BuildContext context, dynamic session) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Membuat laporan PDF...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Generate PDF using PdfService
      final file = await PdfService.generatePredictionReport(session);

      // Close loading dialog
      Get.back();

      // Share the PDF file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Prediksi Random Forest - ${session.flag}',
      );

      Get.snackbar(
        'Berhasil',
        'Laporan PDF siap dibagikan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      // Close loading dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Gagal membuat laporan PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }
}
