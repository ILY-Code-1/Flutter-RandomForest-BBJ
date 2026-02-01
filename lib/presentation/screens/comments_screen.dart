// File: comments_screen.dart
// Halaman untuk melihat dan menambah komentar pada prediction session

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/prediction_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/custom_app_bar.dart';

class CommentsScreen extends StatefulWidget {
  final PredictionSessionModel session;

  const CommentsScreen({super.key, required this.session});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _authController = Get.find<AuthController>();
  List<CommentModel> comments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    comments = List.from(widget.session.comments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUser = _authController.currentUser.value;
    if (currentUser == null) return;

    setState(() => isLoading = true);

    try {
      final comment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.id,
        userName: currentUser.nama,
        userRole: currentUser.role,
        text: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.addComment(widget.session.id, comment);

      setState(() {
        comments.add(comment);
        _commentController.clear();
      });

      Get.snackbar(
        'Berhasil',
        'Komentar berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambah komentar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final currentUser = _authController.currentUser.value;
    if (currentUser == null) return;

    // Hanya bisa hapus komentar sendiri atau admin bisa hapus semua
    if (comment.userId != currentUser.id && !currentUser.isAdmin) {
      Get.snackbar(
        'Error',
        'Anda tidak memiliki akses untuk menghapus komentar ini',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteComment(widget.session.id, comment.id);
        setState(() {
          comments.removeWhere((c) => c.id == comment.id);
        });
        Get.snackbar(
          'Berhasil',
          'Komentar berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menghapus komentar: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authController.currentUser.value;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Komentar'),
      body: Column(
        children: [
          // List komentar
          Expanded(
            child: comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada komentar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final isOwnComment = comment.userId == currentUser?.id;
                      final canDelete = isOwnComment || currentUser?.isAdmin == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            CircleAvatar(
                              backgroundColor: comment.userRole == 'admin'
                                  ? AppColors.primary
                                  : AppColors.secondary,
                              child: Text(
                                comment.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Comment bubble
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isOwnComment
                                      ? AppColors.primaryLight
                                      : AppColors.secondary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isOwnComment
                                        ? AppColors.primary.withOpacity(0.3)
                                        : AppColors.secondary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isOwnComment
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: comment.userRole == 'admin'
                                                ? AppColors.primary
                                                : AppColors.secondary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            comment.userRole.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (canDelete)
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 18),
                                            color: isOwnComment
                                                ? Colors.white70
                                                : Colors.red,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _deleteComment(comment),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isOwnComment
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm')
                                          .format(comment.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isOwnComment
                                            ? Colors.white70
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Input komentar
          Container(
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isLoading ? null : _addComment,
                    icon: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    color: AppColors.primary,
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
