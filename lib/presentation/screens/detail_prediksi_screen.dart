// File: detail_prediksi_screen.dart
// Screen untuk menampilkan detail lengkap hasil prediksi dengan fitur download PDF

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/prediction_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/pdf_service.dart';
import '../../data/models/prediction_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/nasabah_detail_card.dart';
import '../widgets/share_user_dialog.dart';
import 'comments_screen.dart';
import '../../routes/app_routes.dart';

enum FilterStatus { semua, aktif, tidakAktif }

class DetailPrediksiScreen extends StatefulWidget {
  const DetailPrediksiScreen({super.key});

  @override
  State<DetailPrediksiScreen> createState() => _DetailPrediksiScreenState();
}

class _DetailPrediksiScreenState extends State<DetailPrediksiScreen> {
  FilterStatus _selectedFilter = FilterStatus.semua;
  bool _isRefreshing = false;

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);

    try {
      final controller = Get.find<PredictionController>();
      final sessionId = controller.currentSession.value?.id;

      if (sessionId != null) {
        // Reload data dari Firestore
        await controller.loadSessions();

        // Update current session dengan data terbaru
        final updatedSession = controller.predictionSessions.firstWhereOrNull(
          (s) => s.id == sessionId,
        );

        if (updatedSession != null) {
          controller.setCurrentSession(updatedSession);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal refresh data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  List<NasabahModel> _getFilteredNasabah(List<NasabahModel> allNasabah) {
    switch (_selectedFilter) {
      case FilterStatus.aktif:
        return allNasabah.where((n) => n.finalPrediksi == 'Aktif').toList();
      case FilterStatus.tidakAktif:
        return allNasabah.where((n) => n.finalPrediksi == 'Pasif').toList();
      case FilterStatus.semua:
        return allNasabah;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PredictionController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'DETAIL PREDIKSI',
        showBackButton: true,
        actions: [
          // Refresh button
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
          // Share button (admin only)
          if (authController.isAdmin)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                if (controller.currentSession.value != null) {
                  final result = await Get.dialog<bool>(
                    ShareUserDialog(session: controller.currentSession.value!),
                  );
                  // Refresh data jika assignment berhasil
                  if (result == true) {
                    _refreshData();
                  }
                }
              },
            ),
          // Comment button (both roles)
          IconButton(
            icon: const Icon(Icons.comment),
            onPressed: () async {
              if (controller.currentSession.value != null) {
                await Get.to(
                  () =>
                      CommentsScreen(session: controller.currentSession.value!),
                );
                // Refresh data setelah kembali dari halaman komentar
                _refreshData();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final session = controller.currentSession.value;

          if (session == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final filteredNasabah = _getFilteredNasabah(session.nasabahList);
          final nasabahAktif = session.nasabahList
              .where((n) => n.finalPrediksi == 'Aktif')
              .toList();
          final nasabahTidakAktif = session.nasabahList
              .where((n) => n.finalPrediksi == 'Pasif')
              .toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      const SizedBox(height: 12),
                      _buildCommentButton(context, session),
                      const SizedBox(height: 12),
                      _buildFollowUpButton(context, session),
                      const SizedBox(height: 16),
                      _buildSummarySection(nasabahAktif, nasabahTidakAktif),
                      const SizedBox(height: 16),
                      _buildFilterButtons(
                        nasabahAktif.length,
                        nasabahTidakAktif.length,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Detail Nasabah', style: AppTextStyles.h3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${filteredNasabah.length} data',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (filteredNasabah.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada data nasabah',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredNasabah.map(
                          (nasabah) => NasabahDetailCard(nasabah: nasabah),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildSummarySection(
    List<NasabahModel> nasabahAktif,
    List<NasabahModel> nasabahTidakAktif,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.summarize,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ringkasan Hasil Prediksi',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Nasabah Aktif Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nasabah Aktif (${nasabahAktif.length})',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (nasabahAktif.isEmpty)
                      Text(
                        'Tidak ada nasabah dengan prediksi aktif',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: nasabahAktif
                            .map(
                              (n) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.success.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  n.idNasabah,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nasabah Pasif Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cancel,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nasabah Pasif (${nasabahTidakAktif.length})',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (nasabahTidakAktif.isEmpty)
                      Text(
                        'Tidak ada nasabah dengan prediksi pasif',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: nasabahTidakAktif
                            .map(
                              (n) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  n.idNasabah,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(int jumlahAktif, int jumlahTidakAktif) {
    return Container(
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
          Text(
            'Filter Data Nasabah',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'Semua',
                  count: jumlahAktif + jumlahTidakAktif,
                  isSelected: _selectedFilter == FilterStatus.semua,
                  color: AppColors.primary,
                  onTap: () {
                    setState(() {
                      _selectedFilter = FilterStatus.semua;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Aktif',
                  count: jumlahAktif,
                  isSelected: _selectedFilter == FilterStatus.aktif,
                  color: AppColors.success,
                  onTap: () {
                    setState(() {
                      _selectedFilter = FilterStatus.aktif;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Pasif',
                  count: jumlahTidakAktif,
                  isSelected: _selectedFilter == FilterStatus.tidakAktif,
                  color: AppColors.error,
                  onTap: () {
                    setState(() {
                      _selectedFilter = FilterStatus.tidakAktif;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: AppTextStyles.h3.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
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
      child: SizedBox(
        width: double.infinity,
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
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context, dynamic session) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1B5E20)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            if (session != null) {
              await Get.to(() => CommentsScreen(session: session));
              // Refresh data setelah kembali dari halaman komentar
              _refreshData();
            }
          },
          icon: const Icon(Icons.comment, color: Colors.white, size: 24),
          label: Text(
            'Komentar (${session?.comments?.length ?? 0})',
            style: const TextStyle(
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
      ),
    );
  }

  Widget _buildFollowUpButton(BuildContext context, dynamic session) {
    // Hitung jumlah nasabah yang sudah di-follow up
    int followedUpCount = 0;
    if (session != null && session.nasabahList != null) {
      followedUpCount = session.nasabahList
          .where((n) => n.followUpStatus == true)
          .length;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            if (session != null) {
              await Get.toNamed(AppRoutes.followUp);
              // Refresh data setelah kembali dari halaman follow up
              _refreshData();
            }
          },
          icon: const Icon(Icons.assignment_turned_in, color: Colors.white, size: 24),
          label: Text(
            'Follow Up ($followedUpCount/${session?.nasabahList?.length ?? 0})',
            style: const TextStyle(
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
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Laporan Prediksi Random Forest - ${session.flag}');

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
