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
  final _isDownloading = false.obs;

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    try {
      final controller = Get.find<PredictionController>();
      final sessionId = controller.currentSession.value?.id;
      if (sessionId != null) {
        await controller.loadSessions();
        final updatedSession = controller.predictionSessions.firstWhereOrNull(
          (s) => s.id == sessionId,
        );
        if (updatedSession != null) {
          controller.setCurrentSession(updatedSession);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal refresh data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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

  void _showNasabahPopup(BuildContext context, NasabahModel nasabah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (nasabah.finalPrediksi == 'Aktif'
                        ? AppColors.success
                        : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                nasabah.finalPrediksi == 'Aktif'
                    ? Icons.person
                    : Icons.person_off,
                color: nasabah.finalPrediksi == 'Aktif'
                    ? AppColors.success
                    : AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nasabah.idNasabah,
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              _popupRow('Usia', '${nasabah.usia} tahun'),
              _popupRow('Jenis Kelamin', nasabah.jenisKelamin),
              _popupRow('Pekerjaan', nasabah.pekerjaan),
              _popupRow('Pendapatan',
                  'Rp ${_formatNumber(nasabah.pendapatanBulanan)}'),
              _popupRow('Frekuensi Transaksi',
                  '${nasabah.frekuensiTransaksi}x/bulan'),
              _popupRow('Saldo Rata-rata',
                  'Rp ${_formatNumber(nasabah.saldoRataRata)}/bln'),
              _popupRow(
                  'Lama Nasabah', '${nasabah.lamaMenjadiNasabah} bulan'),
              const Divider(),
              _popupRow('Status Aktual', nasabah.statusNasabah,
                  valueColor: nasabah.statusNasabah == 'Aktif'
                      ? AppColors.success
                      : AppColors.error),
              _popupRow('Hasil Prediksi', nasabah.finalPrediksi,
                  valueColor: nasabah.finalPrediksi == 'Aktif'
                      ? AppColors.success
                      : AppColors.error),
              _popupRow('Evaluasi', nasabah.evaluasi,
                  valueColor: nasabah.evaluasi == 'Benar'
                      ? AppColors.success
                      : AppColors.error),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _popupRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
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
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
          if (authController.isAdmin)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                if (controller.currentSession.value != null) {
                  final result = await Get.dialog<bool>(
                    ShareUserDialog(session: controller.currentSession.value!),
                  );
                  if (result == true) _refreshData();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.comment),
            onPressed: () async {
              if (controller.currentSession.value != null) {
                await Get.to(() =>
                    CommentsScreen(session: controller.currentSession.value!));
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
          final nasabahAktif =
              session.nasabahList.where((n) => n.finalPrediksi == 'Aktif').toList();
          final nasabahTidakAktif =
              session.nasabahList.where((n) => n.finalPrediksi == 'Pasif').toList();

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
                  _buildSummarySection(context, nasabahAktif, nasabahTidakAktif),
                  const SizedBox(height: 16),
                  _buildFilterButtons(
                      nasabahAktif.length, nasabahTidakAktif.length),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Detail Nasabah', style: AppTextStyles.h3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
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
                            Icon(Icons.search_off,
                                size: 64,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('Tidak ada data nasabah',
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filteredNasabah
                        .map((nasabah) => NasabahDetailCard(nasabah: nasabah)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
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
                      colors: [AppColors.primary, Color(0xFF1B5E20)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.summarize, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Ringkasan Hasil Prediksi',
                  style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _buildSummaryGroup(
            context: context,
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            title: 'Nasabah Aktif (${nasabahAktif.length})',
            titleColor: AppColors.success,
            badgeColor: AppColors.success,
            nasabahList: nasabahAktif,
            emptyText: 'Tidak ada nasabah dengan prediksi aktif',
          ),
          const SizedBox(height: 16),
          _buildSummaryGroup(
            context: context,
            icon: Icons.cancel,
            iconColor: AppColors.error,
            title: 'Nasabah Pasif (${nasabahTidakAktif.length})',
            titleColor: AppColors.error,
            badgeColor: AppColors.error,
            nasabahList: nasabahTidakAktif,
            emptyText: 'Tidak ada nasabah dengan prediksi pasif',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGroup({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required Color badgeColor,
    required List<NasabahModel> nasabahList,
    required String emptyText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold, color: titleColor)),
              const SizedBox(height: 8),
              if (nasabahList.isEmpty)
                Text(emptyText,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: nasabahList.map((n) {
                    return GestureDetector(
                      onTap: () => _showNasabahPopup(context, n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: badgeColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              n.idNasabah,
                              style: AppTextStyles.caption.copyWith(
                                color: badgeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.info_outline,
                                size: 12, color: badgeColor),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
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
          Text('Filter Data Nasabah',
              style: AppTextStyles.labelLarge
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'Semua',
                  count: jumlahAktif + jumlahTidakAktif,
                  isSelected: _selectedFilter == FilterStatus.semua,
                  color: AppColors.primary,
                  onTap: () =>
                      setState(() => _selectedFilter = FilterStatus.semua),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Aktif',
                  count: jumlahAktif,
                  isSelected: _selectedFilter == FilterStatus.aktif,
                  color: AppColors.success,
                  onTap: () =>
                      setState(() => _selectedFilter = FilterStatus.aktif),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Pasif',
                  count: jumlahTidakAktif,
                  isSelected: _selectedFilter == FilterStatus.tidakAktif,
                  color: AppColors.error,
                  onTap: () =>
                      setState(() => _selectedFilter = FilterStatus.tidakAktif),
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
            color: isSelected ? color : color.withValues(alpha: 0.1),
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
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, dynamic session) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDownloading.value
              ? [Colors.grey.shade500, Colors.grey.shade600]
              : [AppColors.secondary, const Color(0xFF1565C0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (_isDownloading.value ? Colors.grey : AppColors.secondary)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isDownloading.value ? null : () => _downloadReport(context, session),
          icon: _isDownloading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
          label: Text(
            _isDownloading.value ? 'Membuat PDF...' : 'Download Laporan PDF',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ));
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
            color: AppColors.primary.withValues(alpha: 0.3),
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
              _refreshData();
            }
          },
          icon: const Icon(Icons.comment, color: Colors.white, size: 24),
          label: Text(
            'Komentar (${session?.comments?.length ?? 0})',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpButton(BuildContext context, dynamic session) {
    int followedUpCount = 0;
    if (session != null && session.nasabahList != null) {
      followedUpCount =
          session.nasabahList.where((n) => n.followUpStatus == true).length;
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
            color: AppColors.accent.withValues(alpha: 0.3),
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
              _refreshData();
            }
          },
          icon: const Icon(Icons.assignment_turned_in,
              color: Colors.white, size: 24),
          label: Text(
            'Follow Up ($followedUpCount/${session?.nasabahList?.length ?? 0})',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadReport(BuildContext context, dynamic session) async {
    _isDownloading.value = true;
    try {
      final file = await PdfService.generatePredictionReport(session as PredictionSessionModel);

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
    } finally {
      _isDownloading.value = false;
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
