import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/nasabah_controller.dart';
import '../../controllers/prediction_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/nasabah_bbj_model.dart';
import '../widgets/custom_app_bar.dart';

class PilihNasabahPrediksiScreen extends StatefulWidget {
  const PilihNasabahPrediksiScreen({super.key});

  @override
  State<PilihNasabahPrediksiScreen> createState() =>
      _PilihNasabahPrediksiScreenState();
}

class _PilihNasabahPrediksiScreenState
    extends State<PilihNasabahPrediksiScreen> {
  final Set<String> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NasabahBBJModel> _getFiltered(List<NasabahBBJModel> all) {
    var result = all.toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((n) =>
              n.idNasabah.toLowerCase().contains(q) ||
              n.pekerjaan.toLowerCase().contains(q))
          .toList();
    }
    if (_filterStatus != 'Semua') {
      result = result.where((n) => n.statusNasabah == _filterStatus).toList();
    }
    return result;
  }

  Future<void> _startPrediction() async {
    if (_selectedIds.isEmpty) {
      Get.snackbar('Peringatan', 'Pilih minimal 1 nasabah untuk prediksi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    final nasabahController = Get.find<NasabahController>();
    final predController = Get.find<PredictionController>();

    final selected = nasabahController.nasabahList
        .where((n) => _selectedIds.contains(n.id))
        .toList();

    await predController.submitPredictionFromNasabah(selected);
  }

  @override
  Widget build(BuildContext context) {
    final nasabahController = Get.find<NasabahController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'PILIH NASABAH',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildHeader(nasabahController),
          _buildSearchFilter(),
          Expanded(child: _buildList(nasabahController)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(nasabahController),
    );
  }

  Widget _buildHeader(NasabahController controller) {
    return Obx(() => Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF1B5E20)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pilih nasabah untuk diprediksi',
                        style: AppTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(
                        '${_selectedIds.length} dipilih dari ${controller.nasabahList.length} nasabah',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (_selectedIds.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _selectedIds.clear()),
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Bersihkan'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
            ],
          ),
        ));
  }

  Widget _buildSearchFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari ID atau pekerjaan...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
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
              ...['Semua', 'Aktif', 'Pasif'].map((s) {
                final isSelected = _filterStatus == s;
                Color c = s == 'Aktif'
                    ? AppColors.success
                    : s == 'Pasif'
                        ? AppColors.error
                        : AppColors.primary;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filterStatus = s),
                    selectedColor: c,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                );
              }),
              const Spacer(),
              Obx(() {
                final nasabahController = Get.find<NasabahController>();
                final filtered = _getFiltered(nasabahController.nasabahList);
                final allSelected =
                    filtered.every((n) => _selectedIds.contains(n.id));
                return TextButton(
                  onPressed: () {
                    setState(() {
                      if (allSelected) {
                        for (final n in filtered) {
                          _selectedIds.remove(n.id);
                        }
                      } else {
                        for (final n in filtered) {
                          _selectedIds.add(n.id);
                        }
                      }
                    });
                  },
                  child: Text(allSelected ? 'Hapus Semua' : 'Pilih Semua',
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.primary)),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(NasabahController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final filtered = _getFiltered(controller.nasabahList);
      if (filtered.isEmpty) {
        return Center(
          child: Text('Tidak ada nasabah ditemukan',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final nasabah = filtered[index];
          final isSelected = _selectedIds.contains(nasabah.id);
          final isAktif = nasabah.statusNasabah == 'Aktif';
          return _buildNasabahItem(nasabah, isSelected, isAktif);
        },
      );
    });
  }

  Widget _buildNasabahItem(
      NasabahBBJModel nasabah, bool isSelected, bool isAktif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          if (!isSelected)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: CheckboxListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        value: isSelected,
        onChanged: (val) {
          setState(() {
            if (val == true) {
              _selectedIds.add(nasabah.id);
            } else {
              _selectedIds.remove(nasabah.id);
            }
          });
        },
        activeColor: AppColors.primary,
        title: Row(
          children: [
            Text(
              nasabah.idNasabah,
              style:
                  AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isAktif ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                nasabah.statusNasabah,
                style: AppTextStyles.caption.copyWith(
                  color: isAktif ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${nasabah.usia} tahun • ${nasabah.jenisKelamin} • ${nasabah.pekerjaan}',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(NasabahController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final predController = Get.find<PredictionController>();
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: predController.isLoading.value
                  ? null
                  : (_selectedIds.isEmpty ? null : _startPrediction),
              icon: predController.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                predController.isLoading.value
                    ? 'Memproses...'
                    : 'Mulai Prediksi (${_selectedIds.length} nasabah)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedIds.isEmpty
                    ? Colors.grey
                    : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }),
      ),
    );
  }
}
