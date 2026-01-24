// File: form_prediksi_screen.dart
// Screen form untuk input data prediksi nasabah

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/prediction_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';

class FormPrediksiScreen extends StatelessWidget {
  const FormPrediksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PredictionController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: const CustomAppBar(title: 'MULAI PREDIKSI'),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormSection(controller, constraints),
                    const SizedBox(height: 16),
                    _buildTempList(controller),
                    const SizedBox(height: 16),
                    _buildSubmitButton(controller),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildFormSection(
    PredictionController controller,
    BoxConstraints constraints,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Nasabah',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lengkapi informasi nasabah',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'ID Nasabah',
            hint: 'Masukkan ID Nasabah',
            controller: controller.idNasabahController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Usia',
            hint: 'Masukkan usia',
            controller: controller.usiaController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          Obx(
            () => CustomDropdown<String>(
              label: 'Jenis Kelamin',
              value: controller.jenisKelamin.value,
              items: const ['Laki-laki', 'Perempuan'],
              itemLabel: (item) => item,
              onChanged: (value) {
                if (value != null) {
                  controller.jenisKelamin.value = value;
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Pekerjaan',
            hint: 'Masukkan pekerjaan',
            controller: controller.pekerjaanController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Pendapatan Bulanan',
            hint: 'Masukkan pendapatan bulanan',
            controller: controller.pendapatanController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffixIcon: IconButton(
              icon: const Icon(Icons.info_outline, color: AppColors.primary),
              onPressed: () => _showInfoDialog(
                'Pendapatan Bulanan',
                'Masukkan pendapatan bulanan nasabah dalam Rupiah.',
              ),
            ),

          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Frekuensi Transaksi',
            hint: 'Masukkan frekuensi transaksi per bulan',
            controller: controller.frekuensiController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffixIcon: IconButton(
              icon: const Icon(Icons.info_outline, color: AppColors.primary),
              onPressed: () => _showInfoDialog(
                'Frekuensi Transaksi',
                'Jumlah transaksi yang dilakukan nasabah per bulan.',
              ),
            ),

          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Saldo Rata-Rata',
            hint: 'Masukkan saldo rata-rata',
            controller: controller.saldoController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffixIcon: IconButton(
              icon: const Icon(Icons.info_outline, color: AppColors.primary),
              onPressed: () => _showInfoDialog(
                'Saldo Rata-Rata',
                'Rata-rata saldo rekening nasabah dalam Rupiah.',
              ),
            ),

          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Lama Menjadi Nasabah',
            hint: 'Masukkan lama menjadi nasabah (tahun)',
            controller: controller.lamaController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],

          ),
          const SizedBox(height: 16),
          Obx(
            () => CustomDropdown<String>(
              label: 'Status Nasabah',
              value: controller.statusNasabah.value,
              items: const ['Aktif', 'Pasif'],
              itemLabel: (item) => item,
              onChanged: (value) {
                if (value != null) {
                  controller.statusNasabah.value = value;
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButtons(controller),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PredictionController controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: controller.isEditMode.value
                      ? [const Color(0xFFFFA726), const Color(0xFFFF6F00)]
                      : [AppColors.secondary, const Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (controller.isEditMode.value
                                ? const Color(0xFFFFA726)
                                : AppColors.secondary)
                            .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SmallButton(
                text: controller.isEditMode.value ? '✓ Update' : '+ Tambah',
                backgroundColor: Colors.transparent,
                onPressed: () {
                  if (controller.isEditMode.value) {
                    controller.updateNasabahInTemp();
                  } else {
                    controller.addNasabahToTemp();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textSecondary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SmallButton(
                text: controller.isEditMode.value ? '✕ Cancel' : '⟲ Clear',
                backgroundColor: Colors.transparent,
                onPressed: () {
                  controller.clearForm();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempList(PredictionController controller) {
    return Obx(() {
      if (controller.tempNasabahList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.list_alt,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Nasabah',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${controller.tempNasabahList.length} nasabah ditambahkan',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => controller.clearAllTemp(),
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Hapus Semua'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...controller.tempNasabahList.asMap().entries.map((entry) {
              final index = entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.03), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => controller.setEditModeFromTemp(index),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, Color(0xFF1B5E20)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                                  controller.getTempIdNasabah(index),
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  controller.getTempNasabahInfo(index),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  controller.setEditModeFromTemp(index),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                                size: 20,
                              ),
                              onPressed: () =>
                                  controller.removeNasabahFromTemp(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildSubmitButton(PredictionController controller) {
    return Obx(() {
      final isEnabled = controller.tempNasabahList.isNotEmpty;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF1B5E20)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isEnabled ? null : AppColors.textHint,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isEnabled ? () => controller.submitPrediction() : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'SUBMIT PREDIKSI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showInfoDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
