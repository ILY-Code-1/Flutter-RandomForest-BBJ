import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/nasabah_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/nasabah_bbj_model.dart';
import '../widgets/custom_app_bar.dart';
import 'add_edit_nasabah_screen.dart';

class KelolaNasabahScreen extends StatelessWidget {
  const KelolaNasabahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NasabahController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Kelola Nasabah',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadNasabah,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchFilterBar(controller),
          _buildStatBar(controller),
          Expanded(child: _buildNasabahList(controller)),
        ],
      ),
      floatingActionButton: Obx(() => controller.nasabahList.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _confirmSeedData(context, controller),
              label: const Text('Import Data Awal',
                  style: TextStyle(color: Colors.white)),
              icon: controller.isSeeding.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.download, color: Colors.white),
              backgroundColor: AppColors.secondary,
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildSearchFilterBar(NasabahController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (val) => controller.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'Cari ID Nasabah atau Pekerjaan...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Obx(() => Row(
                      children: ['Semua', 'Aktif', 'Pasif'].map((status) {
                        final isSelected = controller.filterStatus.value == status;
                        Color color;
                        if (status == 'Aktif') {
                          color = AppColors.success;
                        } else if (status == 'Pasif') {
                          color = AppColors.error;
                        } else {
                          color = AppColors.primary;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (_) => controller.filterStatus.value = status,
                            selectedColor: color,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            checkmarkColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    )),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(() => const AddEditNasabahScreen());
                  if (result == true) controller.loadNasabah();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Tambah', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(NasabahController controller) {
    return Obx(() => Container(
          color: AppColors.primary.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _statChip('Total', controller.nasabahList.length.toString(), AppColors.primary),
              const SizedBox(width: 8),
              _statChip('Aktif', controller.jumlahAktif.toString(), AppColors.success),
              const SizedBox(width: 8),
              _statChip('Pasif', controller.jumlahPasif.toString(), AppColors.error),
              const Spacer(),
              Text(
                '${controller.filteredList.length} ditampilkan',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ));
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(color: color)),
          const SizedBox(width: 4),
          Text(value,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNasabahList(NasabahController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(
                controller.nasabahList.isEmpty
                    ? 'Belum ada data nasabah.\nKlik "Import Data Awal" untuk mengisi data.'
                    : 'Tidak ada nasabah yang sesuai filter',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadNasabah,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.filteredList.length,
          itemBuilder: (context, index) {
            final nasabah = controller.filteredList[index];
            return _buildNasabahCard(context, nasabah, controller);
          },
        ),
      );
    });
  }

  Widget _buildNasabahCard(
      BuildContext context, NasabahBBJModel nasabah, NasabahController controller) {
    final isAktif = nasabah.statusNasabah == 'Aktif';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isAktif ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isAktif ? Icons.person : Icons.person_off,
            color: isAktif ? AppColors.success : AppColors.error,
            size: 22,
          ),
        ),
        title: Text(
          nasabah.idNasabah,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${nasabah.usia} tahun • ${nasabah.jenisKelamin}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              nasabah.pekerjaan,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isAktif ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: (isAktif ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.3)),
              ),
              child: Text(
                nasabah.statusNasabah,
                style: AppTextStyles.caption.copyWith(
                  color: isAktif ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onSelected: (value) async {
                if (value == 'edit') {
                  final result = await Get.to(() => AddEditNasabahScreen(nasabah: nasabah));
                  if (result == true) controller.loadNasabah();
                } else if (value == 'delete') {
                  _confirmDelete(context, nasabah, controller);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(
                  children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
                )),
                const PopupMenuItem(value: 'delete', child: Row(
                  children: [Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))],
                )),
              ],
            ),
          ],
        ),
        onTap: () => _showNasabahDetail(context, nasabah),
      ),
    );
  }

  void _showNasabahDetail(BuildContext context, NasabahBBJModel nasabah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nasabah.idNasabah,
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Usia', '${nasabah.usia} tahun'),
              _detailRow('Jenis Kelamin', nasabah.jenisKelamin),
              _detailRow('Pekerjaan', nasabah.pekerjaan),
              _detailRow('Pendapatan', 'Rp ${_formatNumber(nasabah.pendapatanBulanan)}'),
              _detailRow('Frekuensi Transaksi', '${nasabah.frekuensiTransaksi}x/bulan'),
              _detailRow('Saldo Rata-rata', 'Rp ${_formatNumber(nasabah.saldoRataRata)}/bln'),
              _detailRow('Lama Nasabah', '${nasabah.lamaMenjadiNasabah} bulan'),
              _detailRow('Status', nasabah.statusNasabah,
                  valueColor: nasabah.statusNasabah == 'Aktif'
                      ? AppColors.success
                      : AppColors.error),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
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
            child: Text(value,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, NasabahBBJModel nasabah, NasabahController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Nasabah'),
        content: Text('Hapus nasabah ${nasabah.idNasabah}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteNasabah(nasabah.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmSeedData(BuildContext context, NasabahController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data Awal'),
        content: const Text(
            'Import 100 data nasabah awal ke Firestore? Pastikan koleksi nasabah_bbj masih kosong.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              controller.seedData();
            },
            child: const Text('Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
