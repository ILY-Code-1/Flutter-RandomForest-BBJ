// File: follow_up_screen.dart
// Halaman untuk mengelola status follow up nasabah

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/prediction_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/prediction_model.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/custom_app_bar.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final authController = Get.find<AuthController>();
  final predictionController = Get.find<PredictionController>();
  final firestoreService = FirestoreService();

  Map<String, bool> followUpStatuses = {};
  bool isLoading = false;
  bool isSaving = false;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeFollowUpStatuses();
  }

  void _initializeFollowUpStatuses() {
    final session = predictionController.currentSession.value;
    if (session != null) {
      followUpStatuses = {
        for (var nasabah in session.nasabahList)
          nasabah.id: nasabah.followUpStatus
      };
    }
  }

  bool get isMarketing => authController.currentUser.value?.isMarketing ?? false;
  bool get isAdmin => authController.currentUser.value?.isAdmin ?? false;

  int get followedUpCount => followUpStatuses.values.where((v) => v).length;
  int get totalNasabah => followUpStatuses.length;
  double get followUpPercentage =>
      totalNasabah > 0 ? (followedUpCount / totalNasabah) * 100 : 0;

  Future<void> _saveFollowUpStatuses() async {
    if (!hasChanges) return;

    final session = predictionController.currentSession.value;
    if (session == null) return;

    setState(() => isSaving = true);

    try {
      await firestoreService.updateMultipleFollowUpStatus(
        session.id,
        followUpStatuses,
      );

      Get.snackbar(
        'Berhasil',
        'Status follow up berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      setState(() {
        hasChanges = false;
      });

      // Kembali ke halaman sebelumnya dan refresh data
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan status follow up: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _onFollowUpChanged(String nasabahId, bool value) {
    if (isAdmin) return; // Admin tidak bisa mengubah status

    setState(() {
      followUpStatuses[nasabahId] = value;
      hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = predictionController.currentSession.value;

    if (session == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Follow Up'),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'FOLLOW UP',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(),
          const SizedBox(height: 16),

          // List Nasabah
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : session.nasabahList.isEmpty
                    ? _buildEmptyState()
                    : _buildNasabahList(session),
          ),

          // Save Button (Marketing only)
          if (isMarketing && hasChanges) _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_turned_in,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Follow Up',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$followedUpCount dari $totalNasabah nasabah',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${followUpPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: followUpPercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNasabahList(PredictionSessionModel session) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: session.nasabahList.length,
      itemBuilder: (context, index) {
        final nasabah = session.nasabahList[index];
        final isFollowedUp = followUpStatuses[nasabah.id] ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            value: isFollowedUp,
            onChanged: isAdmin
                ? null
                : (value) {
                    if (value != null) {
                      _onFollowUpChanged(nasabah.id, value);
                    }
                  },
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    nasabah.idNasabah,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(nasabah.finalPrediksi),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${nasabah.pekerjaan} • ${nasabah.jenisKelamin}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: isFollowedUp
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFollowedUp ? 'Sudah dihubungi' : 'Belum dihubungi',
                      style: AppTextStyles.caption.copyWith(
                        color: isFollowedUp
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            secondary: CircleAvatar(
              backgroundColor: isFollowedUp
                  ? AppColors.success
                  : AppColors.textHint,
              child: Icon(
                isFollowedUp ? Icons.check : Icons.phone_disabled,
                color: Colors.white,
              ),
            ),
            activeColor: AppColors.success,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'Aktif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.success : AppColors.error,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isActive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSaving ? null : _saveFollowUpStatuses,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data nasabah',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
