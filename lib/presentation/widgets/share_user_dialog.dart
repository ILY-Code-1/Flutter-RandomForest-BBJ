// File: share_user_dialog.dart
// Dialog untuk assign user ke prediction session

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/prediction_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/firestore_service.dart';

class ShareUserDialog extends StatefulWidget {
  final PredictionSessionModel session;

  const ShareUserDialog({super.key, required this.session});

  @override
  State<ShareUserDialog> createState() => _ShareUserDialogState();
}

class _ShareUserDialogState extends State<ShareUserDialog> {
  final authController = Get.find<AuthController>();
  final firestoreService = FirestoreService();
  List<UserModel> allUsers = [];
  Set<String> selectedUserIds = {};
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    allUsers = await authController.getAllUsers();
    selectedUserIds = Set.from(widget.session.assignedUserIds);
    setState(() => isLoading = false);
  }

  Future<void> _saveAssignments() async {
    setState(() => isSaving = true);
    
    try {
      await firestoreService.updateAssignedUsers(
        widget.session.id,
        selectedUserIds.toList(),
      );
      
      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'User assignment berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal update assignment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.share, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Bagikan ke User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih user yang dapat melihat prediksi ini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const Divider(height: 24),

            // User list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : allUsers.isEmpty
                      ? const Center(child: Text('Tidak ada user'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: allUsers.length,
                          itemBuilder: (context, index) {
                            final user = allUsers[index];
                            final isSelected = selectedUserIds.contains(user.id);
                            final isCurrentUser = user.id == authController.currentUser.value?.id;

                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: isCurrentUser ? null : (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedUserIds.add(user.id);
                                  } else {
                                    selectedUserIds.remove(user.id);
                                  }
                                });
                              },
                              title: Text(user.nama),
                              subtitle: Text('${user.email} • ${user.role}'),
                              secondary: CircleAvatar(
                                backgroundColor: user.isAdmin
                                    ? AppColors.primary
                                    : AppColors.secondary,
                                child: Text(
                                  user.nama[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              activeColor: AppColors.primary,
                            );
                          },
                        ),
            ),

            // Footer
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedUserIds.length} user dipilih',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: isSaving ? null : () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isSaving ? null : _saveAssignments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
