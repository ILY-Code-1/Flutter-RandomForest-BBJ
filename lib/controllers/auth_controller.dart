// File: auth_controller.dart
// Controller untuk mengelola authentication state (Firestore only)

import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in from session
    _checkSession();
  }

  void _checkSession() {
    // Get current user from auth service (in-memory session)
    currentUser.value = _authService.currentUser;
  }

  // Check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  // Check if user is admin
  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  // Check if user is marketing
  bool get isMarketing => currentUser.value?.isMarketing ?? false;

  // Login
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      
      final user = await _authService.signIn(email, password);
      
      if (user != null) {
        currentUser.value = user;
        Get.snackbar(
          'Berhasil',
          'Login berhasil! Selamat datang ${user.nama}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      currentUser.value = null;
      Get.snackbar(
        'Berhasil',
        'Logout berhasil',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get all users (for admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      return await _authService.getAllUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil daftar user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }

  // Get marketing users
  Future<List<UserModel>> getMarketingUsers() async {
    try {
      return await _authService.getMarketingUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil daftar marketing: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }

  // Create user (admin only)
  Future<bool> createUser({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      await _authService.createUser(
        email: email,
        password: password,
        nama: nama,
        role: role,
      );
      Get.snackbar(
        'Berhasil',
        'User berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update user (admin only)
  Future<bool> updateUser(String uid, {String? nama, String? role, String? password}) async {
    try {
      isLoading.value = true;
      await _authService.updateUser(uid, nama: nama, role: role, password: password);
      Get.snackbar(
        'Berhasil',
        'User berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal update user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete user (admin only)
  Future<bool> deleteUser(String uid) async {
    try {
      isLoading.value = true;
      await _authService.deleteUser(uid);
      Get.snackbar(
        'Berhasil',
        'User berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
