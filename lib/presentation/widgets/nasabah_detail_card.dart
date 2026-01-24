// File: nasabah_detail_card.dart
// Deskripsi: Widget card untuk menampilkan detail nasabah di screen Detail Prediksi.

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/prediction_model.dart';

class NasabahDetailCard extends StatelessWidget {
  final NasabahModel nasabah;

  const NasabahDetailCard({super.key, required this.nasabah});

  @override
  Widget build(BuildContext context) {
    final isAktif = nasabah.prediksiAwal == 'Aktif';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with ID and Badge
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID NASABAH: ${nasabah.idNasabah}',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAktif
                      ? AppColors.badgeGreen.withValues(alpha: 0.2)
                      : AppColors.badgeRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '(Pred. Awal : ${nasabah.prediksiAwal})',
                  style: AppTextStyles.caption.copyWith(
                    color: isAktif ? AppColors.badgeGreen : AppColors.badgeRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Tree Predictions
          ...List.generate(nasabah.prediksiPohon.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.park, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Prediksi Pohon ${index + 1}: ',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    nasabah.prediksiPohon[index],
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: nasabah.prediksiPohon[index] == 'Aktif'
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Final Prediction
          Row(
            children: [
              Text(
                'FINAL PREDIKSI : ',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nasabah.finalPrediksi,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: nasabah.finalPrediksi == 'Aktif'
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Evaluation
          Row(
            children: [
              Text(
                'EVALUASI : ',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nasabah.evaluasi,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: nasabah.evaluasi == 'Benar'
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
